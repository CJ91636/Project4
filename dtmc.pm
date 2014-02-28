dtmc

const int N;

module partyO
        sentBitsO : [0..N+1];
        recdBitsO : [0..N+1];
        turnO : [0..2];
        
        [begin] turnO=0 -> (turnO' = 1);
    
        [sendO] turnO=1 & sentBitsO<N+1 -> (sentBitsO'=sentBitsO+1) & (turnO' = 0);

        [sendR] turnO=0 & recdBitsO<N -> (recdBitsO' = recdBitsO+1) & (turnO' = 1);

        [sendR] turnO=0 & recdBitsO=N ->  (recdBitsO' = recdBitsO+1) & (turnO' = 2);

        [] turnO=2 -> (turnO'=2);

endmodule

module partyR
        sentBitsR : [0..N+1];
        recdBitsR : [0..N+1];
        turnR : [0..1];  

        [begin] turnR=0 -> (turnR'=0);

        [sendO] turnR=0 & recdBitsR<N+1 -> (recdBitsR' = recdBitsR+1) & (turnR'=1);
        
        [sendR] turnR=1 & sentBitsR<(N+1) -> (sentBitsR'=sentBitsR+1) & (turnR'=0);

endmodule
