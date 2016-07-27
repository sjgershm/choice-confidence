choice-confidence
====

Data and analysis functions for Gershman, Goldwater & Otto, "How confidence shapes choice".

Requires the mfit package:
https://github.com/sjgershm/mfit


Data:
bandit_data.csv: two-armed bandit with stationary binary rewards
leapfrog_data.csv: two-armed bandit with non-stationary integer-valued rewards

Columns in data files:
1) subj_idx: subject ID
2) cond: condition (see below)
3) R1: expected reward for option 1
4) R2: expected reward for option 2
5) reward: observed reward
6) choice: chosen option
7) rt: response time (sec)
8) postjudgment: post-choice judgment
9) block: block number

Conditions:
1 = post-choice confidence judgment
2 = post-choice outcome judgment
3 = no post-choice judgment