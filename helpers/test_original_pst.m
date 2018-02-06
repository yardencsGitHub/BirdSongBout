%%
DATA=cellfun(@(x)x.string,BOUT,'UniformOutput',0);
[F_MAT ALPHABET N PI]=pst_build_trans_mat(DATA,6);
TREE = pst_learn(F_MAT,ALPHABET,N,'L',6);