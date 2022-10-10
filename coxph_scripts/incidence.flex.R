library(survival)
library(survminer)
library(lubridate)
library(RColorBrewer)

# get dataframes

# plot by race/ethnic groups

eur=read.table("/group/research/mvp022/PHS/data/phs_files/phs290_eth/eur.male.prs.release4.tsv",sep="\t",header=TRUE)
afr=read.table("/group/research/mvp022/PHS/data/phs_files/phs290_eth/afr.male.prs.release4.tsv",sep="\t",header=TRUE)

# make afr dataframe
afr_km80=afr[which(afr$score>9.639068),]
afr_km20=afr[which(afr$score<9.004659),]
afr_km50=afr[which(afr$score>9.123500 & afr$score<9.519703),]
afr_km95=afr[which(afr$score>9.946332),]

afr_flex_km80=afr[which(afr$score>quantile(afr$score,probs=0.8)),]
afr_flex_km20=afr[which(afr$score<quantile(afr$score,probs=0.2)),]
afr_flex_km50=afr[which(afr$score>quantile(afr$score,probs=0.3) & afr$score<quantile(afr$score,probs=0.7)),]
afr_flex_km95=afr[which(afr$score>quantile(afr$score,probs=0.95)),]

# make eur dataframe
eur_km80=eur[which(eur$score>9.639068),]
eur_km20=eur[which(eur$score<9.004659),]
eur_km50=eur[which(eur$score>9.123500 & eur$score<9.519703),]
eur_flex_km50=eur[which(eur$score>quantile(eur$score,probs=0.3) & eur$score<quantile(eur$score,probs=0.7)),]
eur_km95=eur[which(eur$score>9.946332),]

afr_km80$label="afr 80-100"
afr_km20$label="afr 0-20"
afr_km50$label="afr 30-70"
afr_km95$label="afr 95-100"

afr_flex_km80$label="afr 80-100"
afr_flex_km20$label="afr 0-20"
afr_flex_km50$label="afr 30-70"
afr_flex_km95$label="afr 95-100"

afr_km80$type="hard"
afr_km20$type="hard"
afr_km50$type="hard"
afr_km95$type="hard"

afr_flex_km80$type="flex"
afr_flex_km20$type="flex"
afr_flex_km50$type="flex"
afr_flex_km95$type="flex"

eur_km80$label="eur 80-100"
eur_km20$label="eur 0-20"
eur_km50$label="eur 30-70"
eur_km95$label="eur 95-100"

eur_flex_km50$label="eur 30-70"

eur_km50$type="hard"
eur_flex_km50$type="flex"

df=rbind(afr_flex_km80,afr_flex_km20,afr_flex_km50,afr_flex_km95,eur_flex_km50,afr_km80,afr_km20,afr_km50,afr_km95,eur_km50)

# plot with flexible and hard thresholds

colors=c(brewer.pal(4,"PRGn"),"#563D2D")
colors=replace(colors,2,"#000000")

pdf(file="afr.eur.PC.flex.incidence.km.curves.pdf")
sf <- survfit(Surv(PC_age,PC) ~ label + type, data=df)
p<-ggsurvplot(sf, data=df, fun="event",palette=rep(colors,each=2), linetype=c("type"), break.x.by=10, xlim=c(45,90),ylim=c(0,0.7))
print(p$plot+scale_linetype_manual(values=c("dotted","solid")),newpage=FALSE)
dev.off()
dfplot = p$data.survplot
write.csv(dfplot,"afr.flex.PC.table.csv")

pdf(file="afr.eur.met.flex.incidence.km.curves.pdf")
sf <- survfit(Surv(met_age,met) ~ label + type, data=df)
p<-ggsurvplot(sf, data=df, fun="event",palette=rep(colors,each=2), linetype=c("type"), break.x.by=10, xlim=c(45,90),ylim=c(0,0.15))
print(p$plot+scale_linetype_manual(values=c("dotted","solid")),newpage=FALSE)
dev.off()
dfplot = p$data.survplot
write.csv(dfplot,"afr.flex.met.table.csv")

pdf(file="afr.eur.PC_death.flex.incidence.km.curves.pdf")
sf <- survfit(Surv(PC_death_age,PC_death) ~ label + type, data=df)
p<-ggsurvplot(sf, data=df, fun="event",palette=rep(colors,each=2), linetype=c("type"), break.x.by=10, xlim=c(45,90),ylim=c(0,0.08))
print(p$plot+scale_linetype_manual(values=c("dotted","solid")),newpage=FALSE)
dev.off()
dfplot = p$data.survplot
write.csv(dfplot,"afr.flex.PC_death.table.csv")
