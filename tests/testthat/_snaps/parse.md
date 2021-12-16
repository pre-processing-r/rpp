# parse_text() snapshots

    Code
      as.list(parse_text("a <- 1"))
    Output
      $parsed
      $parsed[[1]]
      a <- 1
      
      
      $srcrefs
      $srcrefs[[1]]
      a <- 1
      
      
      $pre_comments
      $pre_comments[[1]]
      # A tibble: 0 x 9
      # ... with 9 variables: line1 <int>, col1 <int>, line2 <int>, col2 <int>,
      #   id <int>, parent <int>, token <chr>, terminal <lgl>, text <chr>
      
      
      $code
      $code[[1]]
      # A tibble: 6 x 9
        line1  col1 line2  col2    id parent token       terminal text  
        <int> <int> <int> <int> <int>  <int> <chr>       <lgl>    <chr> 
      1     1     1     1     6     7      0 expr        FALSE    a <- 1
      2     1     1     1     1     1      3 SYMBOL      TRUE     a     
      3     1     1     1     1     3      7 expr        FALSE    a     
      4     1     3     1     4     2      7 LEFT_ASSIGN TRUE     <-    
      5     1     6     1     6     4      5 NUM_CONST   TRUE     1     
      6     1     6     1     6     5      7 expr        FALSE    1     
      
      

---

    Code
      as.list(parse_text("#' roxygen2 block\na <- 1"))
    Output
      $parsed
      $parsed[[1]]
      a <- 1
      
      
      $srcrefs
      $srcrefs[[1]]
      a <- 1
      
      
      $pre_comments
      $pre_comments[[1]]
      # A tibble: 1 x 9
        line1  col1 line2  col2    id parent token   terminal text             
        <int> <int> <int> <int> <int>  <int> <chr>   <lgl>    <chr>            
      1     1     1     1    17     1    -10 COMMENT TRUE     #' roxygen2 block
      
      
      $code
      $code[[1]]
      # A tibble: 6 x 9
        line1  col1 line2  col2    id parent token       terminal text  
        <int> <int> <int> <int> <int>  <int> <chr>       <lgl>    <chr> 
      1     2     1     2     6    10      0 expr        FALSE    a <- 1
      2     2     1     2     1     4      6 SYMBOL      TRUE     a     
      3     2     1     2     1     6     10 expr        FALSE    a     
      4     2     3     2     4     5     10 LEFT_ASSIGN TRUE     <-    
      5     2     6     2     6     7      8 NUM_CONST   TRUE     1     
      6     2     6     2     6     8     10 expr        FALSE    1     
      
      

---

    Code
      as.list(parse_text("a <- 1 # inline comment"))
    Output
      $parsed
      $parsed[[1]]
      a <- 1
      
      
      $srcrefs
      $srcrefs[[1]]
      a <- 1
      
      
      $pre_comments
      $pre_comments[[1]]
      # A tibble: 0 x 9
      # ... with 9 variables: line1 <int>, col1 <int>, line2 <int>, col2 <int>,
      #   id <int>, parent <int>, token <chr>, terminal <lgl>, text <chr>
      
      $pre_comments[[2]]
      # A tibble: 0 x 9
      # ... with 9 variables: line1 <int>, col1 <int>, line2 <int>, col2 <int>,
      #   id <int>, parent <int>, token <chr>, terminal <lgl>, text <chr>
      
      
      $code
      $code[[1]]
      # A tibble: 6 x 9
        line1  col1 line2  col2    id parent token       terminal text  
        <int> <int> <int> <int> <int>  <int> <chr>       <lgl>    <chr> 
      1     1     1     1     6     8      0 expr        FALSE    a <- 1
      2     1     1     1     1     1      3 SYMBOL      TRUE     a     
      3     1     1     1     1     3      8 expr        FALSE    a     
      4     1     3     1     4     2      8 LEFT_ASSIGN TRUE     <-    
      5     1     6     1     6     4      5 NUM_CONST   TRUE     1     
      6     1     6     1     6     5      8 expr        FALSE    1     
      
      

---

    Code
      as.list(parse_text("a <- 1\na <- 2"))
    Output
      $parsed
      $parsed[[1]]
      a <- 1
      
      $parsed[[2]]
      a <- 2
      
      
      $srcrefs
      $srcrefs[[1]]
      a <- 1
      
      $srcrefs[[2]]
      a <- 2
      
      
      $pre_comments
      $pre_comments[[1]]
      # A tibble: 0 x 9
      # ... with 9 variables: line1 <int>, col1 <int>, line2 <int>, col2 <int>,
      #   id <int>, parent <int>, token <chr>, terminal <lgl>, text <chr>
      
      $pre_comments[[2]]
      # A tibble: 0 x 9
      # ... with 9 variables: line1 <int>, col1 <int>, line2 <int>, col2 <int>,
      #   id <int>, parent <int>, token <chr>, terminal <lgl>, text <chr>
      
      
      $code
      $code[[1]]
      # A tibble: 6 x 9
        line1  col1 line2  col2    id parent token       terminal text  
        <int> <int> <int> <int> <int>  <int> <chr>       <lgl>    <chr> 
      1     1     1     1     6     7      0 expr        FALSE    a <- 1
      2     1     1     1     1     1      3 SYMBOL      TRUE     a     
      3     1     1     1     1     3      7 expr        FALSE    a     
      4     1     3     1     4     2      7 LEFT_ASSIGN TRUE     <-    
      5     1     6     1     6     4      5 NUM_CONST   TRUE     1     
      6     1     6     1     6     5      7 expr        FALSE    1     
      
      $code[[2]]
      # A tibble: 6 x 9
        line1  col1 line2  col2    id parent token       terminal text  
        <int> <int> <int> <int> <int>  <int> <chr>       <lgl>    <chr> 
      1     2     1     2     6    16      0 expr        FALSE    a <- 2
      2     2     1     2     1    10     12 SYMBOL      TRUE     a     
      3     2     1     2     1    12     16 expr        FALSE    a     
      4     2     3     2     4    11     16 LEFT_ASSIGN TRUE     <-    
      5     2     6     2     6    13     14 NUM_CONST   TRUE     2     
      6     2     6     2     6    14     16 expr        FALSE    2     
      
      

---

    Code
      as.list(parse_text("a <- 1; a <- 2"))
    Output
      $parsed
      $parsed[[1]]
      a <- 1
      
      $parsed[[2]]
      a <- 2
      
      
      $srcrefs
      $srcrefs[[1]]
      a <- 1
      
      $srcrefs[[2]]
      a <- 2
      
      
      $pre_comments
      $pre_comments[[1]]
      # A tibble: 0 x 9
      # ... with 9 variables: line1 <int>, col1 <int>, line2 <int>, col2 <int>,
      #   id <int>, parent <int>, token <chr>, terminal <lgl>, text <chr>
      
      $pre_comments[[2]]
      # A tibble: 1 x 9
        line1  col1 line2  col2    id parent token terminal text 
        <int> <int> <int> <int> <int>  <int> <chr> <lgl>    <chr>
      1     1     7     1     7     6      0 ';'   TRUE     ;    
      
      
      $code
      $code[[1]]
      # A tibble: 6 x 9
        line1  col1 line2  col2    id parent token       terminal text  
        <int> <int> <int> <int> <int>  <int> <chr>       <lgl>    <chr> 
      1     1     1     1     6     7      0 expr        FALSE    a <- 1
      2     1     1     1     1     1      3 SYMBOL      TRUE     a     
      3     1     1     1     1     3      7 expr        FALSE    a     
      4     1     3     1     4     2      7 LEFT_ASSIGN TRUE     <-    
      5     1     6     1     6     4      5 NUM_CONST   TRUE     1     
      6     1     6     1     6     5      7 expr        FALSE    1     
      
      $code[[2]]
      # A tibble: 6 x 9
        line1  col1 line2  col2    id parent token       terminal text  
        <int> <int> <int> <int> <int>  <int> <chr>       <lgl>    <chr> 
      1     1     9     1    14    16      0 expr        FALSE    a <- 2
      2     1     9     1     9    10     12 SYMBOL      TRUE     a     
      3     1     9     1     9    12     16 expr        FALSE    a     
      4     1    11     1    12    11     16 LEFT_ASSIGN TRUE     <-    
      5     1    14     1    14    13     14 NUM_CONST   TRUE     2     
      6     1    14     1    14    14     16 expr        FALSE    2     
      
      

