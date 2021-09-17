from ete3 import Tree
t=Tree('ALLMB.tre',format=1)
sp_nam=[leaf.name for leaf in t]

w=open('ALLMB.sp.list','a')
w.write('\n'.join(sp_nam))
w.close()

#check if genus names in host plant database are legitimate
x=open('ALLMB.sp.list').readlines()
x=[i.split('_')[0] for i in x]
x=list(set(x))


y=open('Poan_HOSTS_combined.genus.list').readlines()
y=[i.strip() for i in y]
#len(y)
#653

#len(x)
#15577

z=[i for i in y if not i in x]
#z
#['Barbula', 'Blechum', 'Bothrocaryum', 'Chaetochloa', 'Citrofortunella', 'Cucumus', 'Cyclobalanopsis', 'Gaylussia', 'Glysine', 'Jasmimum', 'Onosmodium', 'Orbignya', 'Phytolaccus', 'Poncirus', 'Pongamia', 'Pseudogonia', 'Pteridium', 'Sarcostemma', 'Scapania', 'Severinia', 'Tortula']

out=open('Poan_HOSTS_combined.nonALLMB_genus.list','a')
out.write('\n'.join(z))
out.close()


###########################################
##Add crown group age for all species to reduce missing data in MPD analysis
###########################################
from ete3 import Tree
from random import sample

t=Tree('v0.1/ALLMB.tre',format=1)

x=open('ALLMB.sp.list').readlines()
x=[i.strip() for i in x]
#get all species names in ALLMB if they are included in the host plant database
y=open('Poan_HOSTS_combined.genus.list').readlines()
y=[i.strip() for i in y]

ALLMB_genera=[i for i in x if i.split('_')[0] in y]

#create species list per genus
ALLMB_sp_per_genus={}
monophyletic_genus={}
for i in y:
	ALLMB_sp_per_genus[i]=[j for j in ALLMB_genera if j.split('_')[0]==i]


#1st pruning, otherwise locating crown is too slow for a giant tree.
sp2keep=[]
#get two species that span crown for monophyletic genus and all descendants for MRCA of non-monophyletic genus


def find_crown_monophyletic(fam):
	valid_sp=ALLMB_sp_per_genus[fam]
	mrca_fam=t.get_common_ancestor(valid_sp)
	child1=mrca_fam.get_children()[0]
	child2=mrca_fam.get_children()[1]
	child1_sp=[leaf.name for leaf in child1]
	child2_sp=[leaf.name for leaf in child2]
	return([child1_sp[0],child2_sp[0]])


#for paraphyletic groups, the crown age would be defined as the monophyletic clade with the most number of species for this genus
def find_crown_paraphyletic(fam):
	try:
		clade_size=1
		output_sp=[]
		valid_sp=ALLMB_sp_per_genus[fam]
		for sp in valid_sp:
			tip=t&sp
			tip.add_features(family=fam)
		for node in t.get_monophyletic(values=[fam], target_attr="family"):
			if not node.is_leaf() and len(node.get_leaves())>clade_size:
				child1=node.get_children()[0]
				child2=node.get_children()[1]
				clade_size=len(node.get_leaves())
				output_sp=[child1.get_leaves()[0].name,child2.get_leaves()[0].name]
		return(output_sp)
	except IOError:print('family not found: '+ fam)


for genus in ALLMB_sp_per_genus.keys():
	if not ALLMB_sp_per_genus[genus]:
		#print('Genus '+genus+' not found in the tree!')
		continue
	else:
		print('Working on genus '+genus)
		if len(ALLMB_sp_per_genus[genus])==1:
			monophyletic_genus[genus]='T'
			single_leaf=t&ALLMB_sp_per_genus[genus][0]
			sp2keep=sp2keep+ALLMB_sp_per_genus[genus]+[single_leaf.get_closest_leaf()[0].name]
		else:
			ancestor=t.get_common_ancestor(ALLMB_sp_per_genus[genus])
			mrca_sp=[leaf.name for leaf in ancestor]
			if set(mrca_sp) == set(ALLMB_sp_per_genus[genus]):
				#this genus is monophyletic
				monophyletic_genus[genus]='T'
				sp2keep=sp2keep+find_crown_monophyletic(genus)
			else:
				#nonmonophyletic genus
				monophyletic_genus[genus]='F'
				crown_para=find_crown_paraphyletic(genus)
				if len(crown_para)==0:
					try:
						sp2keep=sp2keep+sample(ALLMB_sp_per_genus[genus],2)
					except:
						pass
				else:
					sp2keep=sp2keep+crown_para
				if len(mrca_sp)>5000:
					print('More than 5000 species in genus '+ genus+'!')
				#if len(mrca_sp)<=10000:
				#	sp2keep=sp2keep+mrca_sp
				#else:
					#add these four genera separately
				#	print('More than 10000 species in this genus! '+ genus)

# than 10000 species in this genus! Elytrigia (Elytrigia_heidmaniae, Elytrigia_litoralis)
#More than 10000 species in this genus! Bauhinia (Bauhinia_grevei, Bauhinia_jenningsii)
#More than 10000 species in this genus! Indigofera (Indigofera_ammoxylum, Indigofera_uniflora)
#More than 10000 species in this genus! Millettia (Millettia_thonningii, Millettia_pulchra)
#sp2keep=sp2keep+['Elytrigia_heidmaniae', 'Elytrigia_litoralis', 'Bauhinia_grevei', 'Bauhinia_jenningsii', 'Indigofera_ammoxylum', 'Indigofera_uniflora', 'Millettia_thonningii', 'Millettia_pulchra']

sp2keep=list(set(sp2keep))
out=open('sp2keep.list','a')
out.write('\n'.join(sp2keep))
out.close()
#len(set(sp2keep))
#149153					

t.prune(sp2keep,preserve_branch_length=True)
t.write(outfile='ALLMB.genus_pruned.tre',format=1)


#########################################
#2 species per genus
t=Tree('ALLMB.genus_pruned_round1.tre',format=1)

#prune the tree
d=[]
for i in crown_sp.keys():
	try:
		d=d+crown_sp[i] 
	except:print i

len(d)

t.prune(d,preserve_branch_length=True)
t.write(format=1, outfile="ALLMB.pruned_2spPerFam.tre")

#modify name
d={}
for k in crown_sp.keys():
	try:
		for i in range(0,len(crown_sp[k])):
			d[crown_sp[k][i]]=k+`i+1`
	except:
		pass

for leaf in t:
	leaf.name=d[leaf.name]

t.write(format=1, outfile="ALLMB.pruned_2spPerFam.family_nam.tre")


#######################
#misc
