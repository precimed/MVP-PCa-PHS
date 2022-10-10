library(survival)
library(survminer)
library(lubridate)
library(RColorBrewer)

# get dataframes

# plot by race/ethnic groups

eur=read.table("/group/research/mvp022/PHS/data/phs_files/phs290_eth/eur.male.prs.release4.tsv",sep="\t",header=TRUE)
afr=read.table("/group/research/mvp022/PHS/data/phs_files/phs290_eth/afr.male.prs.release4.tsv",sep="\t",header=TRUE)

# plot eur/afr groups by hazard ratio

afr_km80=afr[which(afr$score>9.639068),]
afr_km20=afr[which(afr$score<9.004659),]
afr_km50=afr[which(afr$score>9.123500 & afr$score<9.519703),]
afr_km95=afr[which(afr$score>9.946332),]

eur_km80=eur[which(eur$score>9.639068),]
eur_km20=eur[which(eur$score<9.004659),]
eur_km50=eur[which(eur$score>9.123500 & eur$score<9.519703),]
eur_km95=eur[which(eur$score>9.946332),]

afr_km80$label="afr 80-100"
afr_km20$label="afr 0-20"
afr_km50$label="afr 30-70"
afr_km95$label="afr 95-100"

eur_km80$label="eur 80-100"
eur_km20$label="eur 0-20"
eur_km50$label="eur 30-70"
eur_km95$label="eur 95-100"

df=rbind(afr_km80,afr_km20,afr_km50,afr_km95,eur_km50)

colors=c(brewer.pal(4,"PRGn"),"#563D2D")
colors=replace(colors,2,"#000000")

pdf(file="afr.eur.pc.incidence.km.curves.pdf")
sf <- survfit(Surv(PC_age,PC) ~ label, data=df)
ggsurvplot(sf, data=df, risk.table=TRUE, risk.table.col="label",fun="event",palette=colors, break.x.by=10, xlim=c(45,90),ylim=c(0,0.7))
dev.off()

pdf(file="afr.eur.met.incidence.km.curves.pdf")
sf <- survfit(Surv(met_age,met) ~ label, data=df)
ggsurvplot(sf, data=df, risk.table=TRUE, risk.table.col="label",fun="event",palette=colors, break.x.by=10, xlim=c(45,90), ylim=c(0,0.15))
dev.off()

pdf(file="afr.eur.death.incidence.km.curves.pdf")
sf <- survfit(Surv(PC_death_age,PC_death) ~ label, data=df)
ggsurvplot(sf, data=df, risk.table=TRUE, risk.table.col="label",fun="event",palette=colors, break.x.by=10,xlim=c(45,90),ylim=c(0,0.15))
dev.off()

pdf(file="afr.eur.pc.incidence.km.curves.no.table.pdf")
sf <- survfit(Surv(PC_age,PC) ~ label, data=df)
ggsurvplot(sf, data=df,fun="event",palette=colors, break.x.by=10,ylim=c(0,0.7), xlim=c(45,90))
dev.off()

pdf(file="afr.eur.met.incidence.km.curves.no.table.pdf")
sf <- survfit(Surv(met_age,met) ~ label, data=df)
ggsurvplot(sf, data=df, fun="event",palette=colors, break.x.by=10, xlim=c(45,90), ylim=c(0,0.15))
dev.off()

pdf(file="afr.eur.death.incidence.km.curves.no.table.pdf")
sf <- survfit(Surv(PC_death_age,PC_death) ~ label, data=df)
ggsurvplot(sf, data=df,fun="event",palette=colors, break.x.by=10,xlim=c(45,90),ylim=c(0,0.15))
dev.off()

# iterate through and get table for each group

for (group in c("eur","afr","his","asn","native","pacific","other","unknown")){
	
	data=read.table(paste("/group/research/mvp022/PHS/data/phs_files/phs290_eth/",group,".male.prs.release4.tsv",sep=""),sep="\t",header=TRUE)
	
	km80=data[which(data$score>9.639068),]
	km20=data[which(data$score<9.004659),]
	km50=data[which(data$score>9.123500 & data$score<9.519703),]
	km95=data[which(data$score>9.946332),]

	km80$label="80-100"
	km20$label="0-20"
	km50$label="30-70"
	km95$label="95-100"

	df=rbind(km80,km20,km50,km95)

	colors=c(rev(brewer.pal(4,"RdBu")))
	colors=replace(colors,2,"#BDBDBD")

	sf <- survfit(Surv(PC_age,PC) ~ label, data=df)
	sfplot <- ggsurvplot(sf, data=df, risk.table=TRUE, risk.table.col="label",fun="event",palette=colors, break.x.by=10,xlim=c(45,90),ylim=c(0,0.15))
	ggsave(file=paste(group,".pc.incidence.km.curves.no.table.pdf",sep=""),print(sfplot))
	dfplot = sfplot$data.survplot
	write.csv(dfplot,paste(group,".pc.table.csv",sep=""))

	sf <- survfit(Surv(met_age,met) ~ label, data=df)
        sfplot <- ggsurvplot(sf, data=df, risk.table=TRUE, risk.table.col="label",fun="event",palette=colors, break.x.by=10,xlim=c(45,90),ylim=c(0,0.15))
        ggsave(file=paste(group,".met.incidence.km.curves.no.table.pdf",sep=""),print(sfplot))
        dfplot = sfplot$data.survplot
        write.csv(dfplot,paste(group,".met.table.csv",sep=""))

	sf <- survfit(Surv(PC_death_age,PC_death) ~ label, data=df)
        sfplot <- ggsurvplot(sf, data=df, risk.table=TRUE, risk.table.col="label",fun="event",palette=colors, break.x.by=10,xlim=c(45,90),ylim=c(0,0.15))
        ggsave(file=paste(group,".death.incidence.km.curves.no.table.pdf",sep=""),print(sfplot))
        dfplot = sfplot$data.survplot
        write.csv(dfplot,paste(group,".death.table.csv",sep=""))
}
