-- Bradford Smith (bsmith8)
-- CS 810B Final Project raft.als
-- 11/28/2016

module raft

open util/ordering[Time]

abstract sig Time {}
sig State extends Time{}{
    -- State must be a part of some election Term
    some @states.this
}
sig Term extends Time{
    states: set State
}
{
    -- Election term must have some states
    some states
}
sig Node {}

pred show{}
run show for 2
