/* Bradford Smith (bsmith8)
 * CS 810B Final Project raft.als
 * 11/29/2016
 */

module raft

open util/ordering[Time]
open util/boolean

abstract sig Time{}
sig State extends Time{}{
    -- State must be a part of some election Term
    some @states.this
}
sig Term extends Time{
    states: set State
}{
    -- election Term must have some states
    some states
}
sig Node{
    leader: State -> one Bool,
    --candidate: State -> one Bool,
    follower: State -> one Bool,
    value: State -> one Int -- a node has one value at a given state
}{
    -- a node must be either leader or follower but not both
    all s: State | isTrue[leader[s]] => !isTrue[follower[s]] or
                  !isTrue[leader[s]] => isTrue[follower[s]] or
                  isTrue[follower[s]] => !isTrue[leader[s]] or
                  !isTrue[follower[s]] => isTrue[leader[s]]
}

fact {
    -- there can be only one leader for every election Term
    -- all t: Term | all n: Node | one n.term & t && isTrue[n.leader]
}

pred show{}
run show for 5 but exactly 2 Node
