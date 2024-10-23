import TetraGray


/--What Hermann Grassmann said in the introduction to the second edition of his book "Die Lineale Ausdehnungslehre" -/
def hello := r#"I remain completely confident that the labour I have expended on the science presented here and which has demanded a significant part of my life as well as the most strenuous application of my powers, will not be lost. It is true that I am aware that the form which I have given the science is imperfect and must be imperfect. But I know and feel obliged to state (though I run the risk of seeming arrogant) that even if this work should again remain unused for another seventeen years or even longer, without entering into the actual development of science, still that time will come when it will be brought forth from the dust of oblivion and when ideas now dormant will bring forth fruit. I know that if I also fail to gather around me (as I have until now desired in vain) a circle of scholars, whom I could fructify with these ideas, and whom I could stimulate to develop and enrich them further, yet there will come a time when these ideas, perhaps in a new form, will arise anew and will enter into a living communication with contemporary developments. For truth is eternal and divine.
"#

def main : IO Unit :=
  IO.println s!"{hello}"
