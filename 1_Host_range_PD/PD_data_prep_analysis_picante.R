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
#calculate PD, MPD, MNTD
library(picante)
sptree=read.tree('ALLMB.genus_pruned.modified_names.tre')
host_recs=read.csv('host_db.picante_input.Poan_HOSTS.csv',row.names = 1)

#PD
pd.result <- pd(host_recs, sptree, include.root=TRUE)
#41 species have no host plant recs (lichens, ants, etc.)
write.table(pd.result,'pd.Poan_HOSTS.tsv',sep='\t')

#MPD nad MNTD
phydist=cophenetic(sptree)
ses.mpd.result <- ses.mpd(host_recs, phydist, null.model = "taxa.labels",abundance.weighted = FALSE, runs = 199)
write.table(ses.mpd.result,'mpd.Poan_HOSTS.tsv',sep='\t')
ses.mntd.result <- ses.mntd(host_recs, phydist, null.model = "taxa.labels",abundance.weighted = FALSE, runs = 199)
write.table(ses.mntd.result,'mntd.Poan_HOSTS.tsv',sep='\t')


####################################
#consolidate results
x=read.csv('Life_history_traits.csv',row.names = 1,stringsAsFactors = F)

for (i in 1:length(x$PD)){
	x$PD[i]=pd.result[rownames(x)[i],'PD']
	x$Genus_num[i]=pd.result[rownames(x)[i],'SR']
	x$MPD[i]=ses.mpd.result[rownames(x)[i],'mpd.obs']
	x$MPD.z[i]=ses.mpd.result[rownames(x)[i],'mpd.obs.z']
	x$MNTD[i]=ses.mntd.result[rownames(x)[i],'mntd.obs']
	x$MNTD.z[i]=ses.mntd.result[rownames(x)[i],'mntd.obs.z']
}

write.csv(x,'Life_history_traits.Poan_HOSTS_combined.PD_MPD_MNTD.csv')


############
#Plotting
boxplot(x$PD[x$Adult.diel.activity..Kawahara.ADA.==0],x$PD[x$Adult.diel.activity..Kawahara.ADA.==1],x$PD[x$Adult.diel.activity..Kawahara.ADA.==2],x$PD[x$Adult.diel.activity..Kawahara.ADA.==3],ylim=c(0,3000),main='PD')

boxplot(x$Genus_num[x$Adult.diel.activity..Kawahara.ADA.==0],x$Genus_num[x$Adult.diel.activity..Kawahara.ADA.==1],x$Genus_num[x$Adult.diel.activity..Kawahara.ADA.==2],x$Genus_num[x$Adult.diel.activity..Kawahara.ADA.==3],ylim=c(0,50),main='Number of host genera')

boxplot(x$MPD[x$Adult.diel.activity..Kawahara.ADA.==0],x$MPD[x$Adult.diel.activity..Kawahara.ADA.==1],x$MPD[x$Adult.diel.activity..Kawahara.ADA.==2],x$MPD[x$Adult.diel.activity..Kawahara.ADA.==3],ylim=c(0,400),main='MPD')

boxplot(x$MPD.z[x$Adult.diel.activity..Kawahara.ADA.==0],x$MPD.z[x$Adult.diel.activity..Kawahara.ADA.==1],x$MPD.z[x$Adult.diel.activity..Kawahara.ADA.==2],x$MPD.z[x$Adult.diel.activity..Kawahara.ADA.==3],ylim=c(-8,3),main='normalized MPD')

boxplot(x$MNTD[x$Adult.diel.activity..Kawahara.ADA.==0],x$MNTD[x$Adult.diel.activity..Kawahara.ADA.==1],x$MNTD[x$Adult.diel.activity..Kawahara.ADA.==2],x$MNTD[x$Adult.diel.activity..Kawahara.ADA.==3],ylim=c(0,300),main='MNTD')

boxplot(x$MNTD.z[x$Adult.diel.activity..Kawahara.ADA.==0],x$MNTD.z[x$Adult.diel.activity..Kawahara.ADA.==1],x$MNTD.z[x$Adult.diel.activity..Kawahara.ADA.==2],x$MNTD.z[x$Adult.diel.activity..Kawahara.ADA.==3],ylim=c(-6,2),main='normalized MNTD')
