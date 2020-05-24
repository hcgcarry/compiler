1.如果遇到identifier就load進來 assign的左邊會有問題,因為不會希望它load近來,所以我們會在assign的end做一個swap 再把之前load
近來的左邊那個variable pop ,因為執行到assign的ending rule的時候基本上右邊已經reduce成一個了,所以這樣swap在pop調是可行的,
但是如果assign是 ＋＝ *=這種的 就沒有必要pop調,反而剛好可以做運算


2.array在assign左邊的問題：
 rray如果照著作法1去把它load近來之後在pop調,assign end的時候要存回去,會不知道index是多少,所以我們
 parse到 identifier [index] 的時候就給它只做aload 和 lc index,不做iaload,
 在unaryExpression-> expression那邊在判斷是否是array是的話在做iaload,因為會作到這個reduce就是因為要做運算,是LHS


 3.不要在同樣prefix的情況下,production的中間插入rule,這樣會有shift/reduce or reduce /reduce的問題
 ex:
 ForStmt
    : FOR {forstmt();} condition end
    | FOR clause end

同樣prefix FOR,插入一個rule,這個rule會變成一個token,因為它只要empty就可以reduce,所以如果目前的state
是 FOR . , 接下來不知道要先reduce 成那個rule 的token 還是shift,因為如果reduce了那就確定是走第一個rule了
因為第二個rule 沒有那個token


4.if else 那邊要給判斷失敗的跳到下一個if else 判斷的label的index跟整體if else的index不一樣,因為一個整體的if else
可以有多個判斷