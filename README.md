draw-cons-tree
==============

Draw an ASCII picture of a cons tree.

    (draw-cons-tree '(a b (c nil 1)))
    
    [o|o]---[o|o]---[o|/]
     |       |       |      
     a       b      [o|o]---[o|o]---[o|/]
                     |       |       |      
                     c      nil      1      



    (draw-cons-tree '(a b (c nil 1) (t 2 (A B C))))

    [o|o]---[o|o]---[o|o]---[o|/]
     |       |       |       |      
     a       b       |      [o|o]---[o|o]---[o|/]
                     |       |       |       |      
                     |       t       2      [o|o]---[o|o]---[o|/]
                     |                       |       |       |      
                     |                       A       B       C      
                     |      
                    [o|o]---[o|o]---[o|/]
                     |       |       |      
                     c      nil      1      



Ported from the function library of "Scheme 9 from Empty Space"
    http://www.t3x.org/s9fes/draw-tree.scm.html

Library is in the public domain in keeping with the original
