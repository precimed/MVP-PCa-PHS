library(survival)
library(survminer)
library(lubridate)
library(RColorBrewer)

# get dataframes

# plot incidence curves for full MVP

all=read.table("/group/research/mvp022/PHS/data/phs_files/phs290_eth/all.male.prs.release4.tsv",sep="\t",header=TRUE)
all$group <- NULL

all$label="ALL"
print(dim(all))

all=na.omit(all,"PC")
all=na.omit(all,"met")
all=na.omit(all,"PC_death")
all=na.omit(all,"PC_age")
all=na.omit(all,"met_age")
all=na.omit(all,"PC_death_age")
print(dim(all))
# plot by hazard ratio
km80=all[which(all$score>9.639068),]
km20=all[which(all$score<9.004659),]
km50=all[which(all$score>9.123500 & all$score<9.519703),]
km95=all[which(all$score>9.946332),]

km80$label="80-100"
km20$label="0-20"
km50$label="30-70"
km95$label="95-100"

df=rbind(km80,km20,km50,km95)

colors=c(rev(brewer.pal(4,"RdBu")))
colors=replace(colors,2,"#BDBDBD")

# plot with risk table

pdf(file="pc.incidence.km.curves.pdf")
sf <- survfit(Surv(PC_age,PC) ~ label, data=df)
ggsurvplot(sf, data=df, risk.table=TRUE, risk.table.col="label",fun="event",palette=colors, break.x.by=10,ylim=c(0,0.7),xlim=c(45,90))
dev.off()

pdf(file="met.incidence.km.curves.pdf")
sf <- survfit(Surv(met_age,met) ~ label, data=df)
ggsurvplot(sf, data=df, risk.table=TRUE, risk.table.col="label",fun="event",palette=colors, break.x.by=10,xlim=c(45,90),ylim=c(0,0.15))
dev.off()

pdf(file="death.incidence.km.curves.pdf")
sf <- survfit(Surv(PC_death_age,PC_death) ~ label, data=df)
ggsurvplot(sf, data=df, risk.table=TRUE, risk.table.col="label",fun="event",palette=colors, break.x.by=10, xlim=c(45,90),ylim=c(0,0.15))
dev.off()

# plot with risk table

pdf(file="pc.incidence.km.curves.no.table.pdf")
sf <- survfit(Surv(PC_age,PC) ~ label, data=df)
sfplot <- ggsurvplot(sf, data=df,fun="event",palette=colors, break.x.by=10,ylim=c(0,0.7),xlim=c(45,90))
ggsave(file="pc.incidence.km.curves.no.table.pdf",print(sfplot))
dfplot = sfplot$data.survplot
write.csv(dfplot,"pc.table.csv")

pdf(file="met.incidence.km.curves.no.table.pdf")
sf <- survfit(Surv(met_age,met) ~ label, data=df)
sfplot <- ggsurvplot(sf, data=df, risk.table=TRUE, risk.table.col="label",fun="event",palette=colors, break.x.by=10,xlim=c(45,90),ylim=c(0,0.15))
ggsave(file="met.incidence.km.curves.no.table.pdf",print(sfplot))
dfplot = sfplot$data.survplot
write.csv(dfplot,"met.table.csv")

pdf(file="death.incidence.km.curves.no.table.pdf")
sf <- survfit(Surv(PC_death_age,PC_death) ~ label, data=df)
sfplot <- ggsurvplot(sf, data=df, risk.table=TRUE, risk.table.col="label",fun="event",palette=colors, break.x.by=10,xlim=c(45,90),ylim=c(0,0.15))
ggsave(file="death.incidence.km.curves.no.table.pdf",print(sfplot))
dfplot = sfplot$data.survplot
write.csv(dfplot,"red.table.csv")



