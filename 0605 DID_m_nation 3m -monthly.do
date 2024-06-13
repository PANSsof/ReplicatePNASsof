cls
graph set window fontface "Times New Roman"
import delimited "0606-df_user_nation_treat_m_save.csv", case(preserve) clear
encode version_User_Id, generate(country_id)
gen policy = month_nb - 23

gen tt=treat*after
gen ln_pure_string_len=log(1+pure_body_string_len)
gen ln_Q_Score =log(1+Q_Score)
gen ln_Q_ViewCount =log(1+Q_ViewCount)
gen ln_Q_AnswerCount =log(1+Q_AnswerCount)
gen ln_Q_body_string_len=log(1+Q_body_string_len)
gen ln_Q_Tags_len_filter=log(1+Q_Tags_len_filter)
gen ln_Score= log(1+Score)
egen std_Q_Tags_len_filter = std(Q_Tags_len_filter)

gen ln_Up_vote =log(1+Up_vote)
gen ln_Down_vote=log(1+Down_vote)
gen ln_TotalComment =log(1+TotalComment)
gen ln_AnswerComment =log(1+AnswerComment)
gen ln_QuestionerComment =log(1+QuestionerComment)
gen ln_ViewerComment=log(1+ViewerComment)
sum ln_TotalComment ln_AnswerComment ln_QuestionerComment ln_ViewerComment

xtset country_id month_nb
// Accept_ratio ln_Up_vote_mean ln_Down_vote_mean 

global control_fe "ln_Q_ViewCount ln_Q_AnswerCount ln_Q_Score ln_Q_body_string_len  ln_Up_vote ln_Down_vote"

global control_fe "ln_Q_ViewCount ln_Q_AnswerCount ln_Q_Score ln_Q_body_string_len  ln_Up_vote ln_Down_vote"

forvalues i = 11(-1)1{
  gen pre_`i' = (policy == -`i' & treat == 1) 
}

gen current = (policy == 0 & treat == 1)

forvalues j = 1(1)12{
  gen  post_`j' = (policy == `j' & treat == 1)
}

drop pre_1 //



logout,save(img3m_m/descriptive_statistics)word replace:tabstat ln_Score ln_pure_string_len pure_body_smog_index full_code_string_ratio tt ln_TotalComment ln_AnswerComment ln_QuestionerComment ln_ViewerComment Q_Tags_len_filter std_Q_Tags_len_filter median_Q_Tags_len_filter $control_fe,s(N mean sd min max) f(%12.3f) c(s)


wmtcorr ln_Score ln_pure_string_len pure_body_smog_index full_code_string_ratio tt ln_TotalComment ln_AnswerComment ln_QuestionerComment ln_ViewerComment Q_Tags_len_filter std_Q_Tags_len_filter median_Q_Tags_len_filter $control_fe using img3m_m/correlationship.rtf, replace

***1 
reghdfe ln_Score pre_* current  post_* i.month_nb $control_fe, a(country_id month_nb nation) vce(cluster country_id)
est store ptt1

forvalues i = 4(-1)2{
  gen b_pre_`i' = _b[pre_`i']
}
egen avg_coef = rowmean(b_pre_*)
su avg_coef
return list

coefplot, baselevels ///
keep(pre_* current post_*) ///
vertical /// 
transform(*=@-r(mean)) /// 
yline(0, lcolor(edkblue*0.8)) /// 
xline(4, lwidth(vthin) lpattern(dash) lcolor(teal)) ///
ylabel(, labsize(*0.75)) xlabel(, labsize(*0.75)) ///
ytitle("Policy Dynamic Effects", size(small)) /// 
xtitle("Avg_rating{subscript:it}", size(small)) /// 
addplot(line @b @at) /// 
ciopts(lpattern(dash) recast(rcap) msize(medium)) /// 
msymbol(circle_hollow) ///
scheme(s1mono)
graph export "img3m_m/Parallel ln_Score.svg", replace
graph save pt1, replace
drop b_pre_* avg_coef

***2 
reghdfe ln_pure_string_len  pre_* current  post_* i.month_nb $control_fe, a(country_id month_nb nation) vce(cluster  country_id)
est store ptt2

forvalues i = 4(-1)2{
  gen b_pre_`i' = _b[pre_`i']
}
egen avg_coef = rowmean(b_pre_*)
su avg_coef
return list

coefplot, baselevels ///
keep(pre_* current post_*) ///
vertical /// 
transform(*=@-r(mean)) /// 
yline(0, lcolor(edkblue*0.8)) /// 
xline(4, lwidth(vthin) lpattern(dash) lcolor(teal)) ///
ylabel(, labsize(*0.75)) xlabel(, labsize(*0.75)) ///
ytitle("Policy Dynamic Effects", size(small)) /// 
xtitle("Concrete", size(small)) /// 
addplot(line @b @at) /// 
ciopts(lpattern(dash) recast(rcap) msize(medium)) /// 
msymbol(circle_hollow) /// 
scheme(s1mono)
graph export "img3m_m/Parallel de_ln_pure_string_len.svg", replace
graph save pt2, replace
drop b_pre_* avg_coef

***3 
reghdfe pure_body_smog_index pre_* current  post_* i.month_nb $control_fe, a(country_id month_nb nation) vce(cluster country_id)
est store ptt3

forvalues i = 4(-1)2{
  gen b_pre_`i' = _b[pre_`i']
}
egen avg_coef = rowmean(b_pre_*)
su avg_coef
return list

coefplot, baselevels ///
keep(pre_* current post_*) ///
vertical /// 
transform(*=@-r(mean)) /// 
yline(0, lcolor(edkblue*0.8)) /// 
xline(4, lwidth(vthin) lpattern(dash) lcolor(teal)) ///
ylabel(, labsize(*0.75)) xlabel(, labsize(*0.75)) ///
ytitle("Policy Dynamic Effects", size(small)) ///
xtitle("Readability", size(small)) /// 
addplot(line @b @at) ///
ciopts(lpattern(dash) recast(rcap) msize(medium)) /// 
msymbol(circle_hollow) ///
scheme(s1mono)
graph export "img3m_m/Parallel de_pure_body_smog_index.svg", replace
graph save pt3, replace
drop b_pre_* avg_coef

***10 
reghdfe full_code_string_ratio  pre_* current  post_* i.month_nb $control_fe, a(country_id month_nb nation) vce(cluster country_id)

forvalues i = 4(-1)2{
  gen b_pre_`i' = _b[pre_`i']
}
egen avg_coef = rowmean(b_pre_*)
su avg_coef
return list

coefplot, baselevels ///
keep(pre_* current post_*) ///
vertical /// 
transform(*=@-r(mean)) /// 
yline(0, lcolor(edkblue*0.8)) /// 
xline(4, lwidth(vthin) lpattern(dash) lcolor(teal)) ///
ylabel(, labsize(*0.75)) xlabel(, labsize(*0.75)) ///
ytitle("Policy Dynamic Effects", size(small)) /// 
xtitle("Code_ratio", size(small)) /// 
addplot(line @b @at) /// 
ciopts(lpattern(dash) recast(rcap) msize(medium)) /// 
msymbol(circle_hollow) /// 
scheme(s1mono)
graph export "img3m_m/Parallel de_full_code_string_ratio.svg", replace
graph save pt4, replace
drop b_pre_* avg_coef

graph combine pt1.gph pt2.gph pt3.gph pt4.gph, col(2)
graph export "img3m_m/Parallel_pans.svg", replace 

* 主回归
reghdfe ln_Score tt $control_fe, a(country_id month_nb) vce(cluster country_id nation)
est store m11

reghdfe ln_pure_string_len  tt $control_fe, a(country_id month_nb nation) vce(cluster country_id)
est store m12

reghdfe pure_body_smog_index  tt $control_fe, a(country_id month_nb nation) vce(cluster country_id)
est store m13

reghdfe full_code_string_ratio  tt $control_fe, a(country_id month_nb nation) vce(cluster country_id)
est store m14
esttab m11 m12 m13 m14 using "img3m_m/DID_RegreeModel3m.rtf",se replace 

***moderate effect ln_Q_Tags_len_filter
reghdfe ln_Score c.std_Q_Tags_len_filter  $control_fe, a(country_id month_nb) vce(cluster country_id)
est store mw31std
reghdfe ln_Score c.tt c.std_Q_Tags_len_filter  $control_fe, a(country_id month_nb) vce(cluster country_id)
est store mw311std
reghdfe ln_Score c.tt##c.std_Q_Tags_len_filter  $control_fe, a(country_id month_nb) vce(cluster country_id)
est store mw32std
esttab mw31std mw311std mw32std using img3m_m/DIDRegression3mModerate_ln_Q_Tags_len_filter＿std.rtf,se replace 


* 
su tt if e(sample)
local low_tt = r(mean) - r(sd)
local high_tt = r(mean) + r(sd)

* 
su std_Q_Tags_len_filter if e(sample)
local mean_std_Q_Tags_len_filter = r(mean)
local sd_std_Q_Tags_len_filter = r(sd)

local low_std_Q_Tags_len_filter = `mean_std_Q_Tags_len_filter' - `sd_std_Q_Tags_len_filter'
local high_std_Q_Tags_len_filter = `mean_std_Q_Tags_len_filter' + `sd_std_Q_Tags_len_filter'

* 
est restore mw32std
* 
margins, at(tt=(`low_tt' `high_tt') std_Q_Tags_len_filter=(`low_std_Q_Tags_len_filter' `high_std_Q_Tags_len_filter'))
marginsplot, xlabel(-1 "Low AI Augmenting" 1 "High AI Augmenting") ///
            xtitle("AI Augmenting") ///
            ytitle("Predicted Answer Length") ///
            ylabel(, angle(horizontal) nogrid) ///
            legend(position(3) col(1) stack) ////
            title("Moderating Effect of Question Diversity to Answer Length") noci
graph export "img3m_m/moderate effect flenmw32std.jpg", replace


//*******************************增加comment*****************************************
reghdfe ln_TotalComment tt $control_fe, a(country_id month_nb) vce(cluster country_id nation)
est store m13

reghdfe ln_AnswerComment  tt $control_fe, a(country_id month_nb nation) vce(cluster country_id)
est store m18

reghdfe ln_QuestionerComment  tt $control_fe, a(country_id month_nb nation) vce(cluster country_id)
est store m19
reghdfe ln_ViewerComment  tt $control_fe, a(country_id month_nb nation) vce(cluster country_id)
est store m110
esttab m13 m18 m19 m110 using "img3m_m/DIDRegreeModel_3m_comment.rtf",se replace 


//************** Q_Tags_len_filter group regression******************
reghdfe ln_Score tt $control_fe, a(country_id month_nb nation) vce(cluster country_id) keepsingletons, if median_Q_Tags_len_filter==1
est store mw1

reghdfe ln_Score tt $control_fe, a(country_id month_nb nation) vce(cluster country_id) keepsingletons, if median_Q_Tags_len_filter==0
est store mw2

esttab mw1 mw2 using img3m_m/DIDRegressionModel3mGroup.rtf, se replace

//*******************************placebo**************************************
gen did=treat*after

reghdfe ln_Score did , a(country_id month_nb nation) vce(cluster country_id)
cap erase "img3m_m/ln_Score simulations.dta"
permute did beta = _b[did] se= _se[did] df = e(df_r), reps(500) rseed(42) saving("img3m_m/ln_Score simulations.dta"):reghdfe ln_Score did, a(country_id month_nb nation) vce(cluster country_id)

***plot
use "img3m_m/ln_Score simulations.dta", clear
gen t_value= beta/se
gen p_value=2*ttail(df, abs(beta/se))
dpplot beta, xline(0.047,lp(dash)) xtitle("Estimator") ytitle("Density") ///
    text(0 0.047 "0.047" )
graph save placet31, replace
graph export "img3m_m/Placebo-ln_Score.png", replace

