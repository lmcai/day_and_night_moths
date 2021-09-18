####################################
#INPUT prep


y=read.csv('Poan_HOST_combined.picante_input.tsv',row.names=1,stringsAsFactors = F,sep='\t')
x=read.csv('Poan_HOST_combined_genus_nonredundant_matchALLMB.csv')



#if the butterfly has only one host genus, then mark the second species within this family to use crown group age for PD
z=read.table('./misc/Poan_HOST_combined.genus_number.tsv',sep='\t',row.names=1,stringsAsFactors = F)


for (i in 1:length(x$Host.genus)){
	y[as.character(x$Butterfly.species.name[i]),paste(as.character(x$Host.genus[i]),'_1',sep='')]=1
	#if only one genus, mark the second placeholder as "1" as well
	if (z[as.character(x$Butterfly.species.name[i]),]==1){
		y[as.character(x$Butterfly.species.name[i]),paste(as.character(x$Host.genus[i]),'_2',sep='')]=1
	}
}


write.csv(y,'host_db.picante_input.Poan_HOSTS.csv')

####################################
#
library(picante)
sptree=read.tree('ALLMB.genus_pruned.modified_names.tre')
host_recs=read.csv('host_db.picante_input.Poan_HOSTS.csv',row.names = 1)
pd.result <- pd(host_recs, sptree, include.root=TRUE)
#41 species have no host plant recs (lichens, ants, etc.)
write.table(pd.result,'pd.Poan_HOSTS.tsv',sep='\t')

#MPD
phydist=cophenetic(sptree)
ses.mpd.result <- ses.mpd(host_recs, phydist, null.model = "taxa.labels",abundance.weighted = FALSE, runs = 99)
write.table(ses.mpd.result,'mpd.allRecs.tsv',sep='\t')
#417 species have MPD values (more than two host plant families)
ses.mntd.result <- ses.mntd(host_recs, phydist, null.model = "taxa.labels",abundance.weighted = FALSE, runs = 99)
write.table(ses.mntd.result,'mntd.allRecs.tsv',sep='\t')

###
#filter for number of records
host_recs_filtered=read.csv('Hosts_families4picante_atLeast1source.csv',row.names = 1)
pd.filtered.result <- pd(host_recs_filtered, sptree, include.root=TRUE)
write.table(pd.filtered.result,'pd.atLeast1source.tsv',sep='\t')

sptree=read.tree('ALLMB.pruned_2spPerFam.family_nam.tre')
phydist=cophenetic(sptree)

host_recs_filtered=read.csv('Hosts_families_2sp_per_fam_4picante_atLeast1source.csv',row.names = 1)
ses.mpd.filtered.result <- ses.mpd(host_recs_filtered, phydist, null.model = "taxa.labels",abundance.weighted = FALSE, runs = 999)
ses.mntd.result <- ses.mntd(host_recs_filtered, phydist, null.model = "taxa.labels",abundance.weighted = FALSE, runs = 999)
write.table(ses.mpd.filtered.result,'mpd.atLeast1source.tsv',sep='\t')
write.table(ses.mntd.result,'mntd.atLeast1source.tsv',sep='\t')

##############################
#two tips per family
##############################
y=read.csv('Hosts_families4picante_null.tsv',row.names=1)
for (i in 1:length(x$Tree_label)){
	y[as.character(x$Lep_accepted_name[i]),paste(x$Host_family[i],'1',sep='')]=1
}

#if the butterfly has only one host family, then mark the second species within this family to use crown group age for PD
z=read.table('result_sum.tsv',sep='\t',header=T)
for (i in 1:length(z$Tree_label)){
	if (z$Num.families[i]==1){
		y[as.character(z$Lep_accepted_name[i]),paste(x$Host_family[x$Lep_accepted_name==z$Lep_accepted_name[i]],'2',sep='')]=1
	}
}

write.csv(y,'Hosts_families_2sp_per_fam_4picante_all_recs.csv')


#calculating PD in picante
library(picante)
sptree=read.tree('ALLMB.pruned_2spPerFam.family_nam.tre')
host_recs=read.csv('Hosts_families_2sp_per_fam_4picante_all_recs.csv',row.names = 1)
#pd.result <- pd(host_recs, sptree, include.root=TRUE)
#41 species have no host plant recs (lichens, ants, etc.)
#write.table(pd.result,'pd.allRecs.tsv',sep='\t')

#MPD
phydist=cophenetic(sptree)
ses.mpd.result <- ses.mpd(host_recs, phydist, null.model = "taxa.labels",abundance.weighted = FALSE, runs = 999)
write.table(ses.mpd.result,'mpd.allRecs.tsv',sep='\t')
#417 species have MPD values (more than two host plant families)
ses.mntd.result <- ses.mntd(host_recs, phydist, null.model = "taxa.labels",abundance.weighted = FALSE, runs = 999)
write.table(ses.mntd.result,'mntd.allRecs.tsv',sep='\t')