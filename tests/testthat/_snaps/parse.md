# parse_text() snapshots

    Code
      as.list(parse_text("a <- 1"))
    Output
      $filename
      [1] "<text>"
      
      $code
      $code[[1]]
      a <- 1
      
      
      $srcref
      $srcref[[1]]
      a <- 1
      
      
      $parse_data
      $parse_data[[1]]
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
      $filename
      [1] "<text>"
      
      $code
      $code[[1]]
      a <- 1
      
      
      $srcref
      $srcref[[1]]
      a <- 1
      
      
      $parse_data
      $parse_data[[1]]
      # A tibble: 7 x 9
        line1  col1 line2  col2    id parent token       terminal text             
        <int> <int> <int> <int> <int>  <int> <chr>       <lgl>    <chr>            
      1     1     1     1    17     1    -10 COMMENT     TRUE     #' roxygen2 block
      2     2     1     2     6    10      0 expr        FALSE    a <- 1           
      3     2     1     2     1     4      6 SYMBOL      TRUE     a                
      4     2     1     2     1     6     10 expr        FALSE    a                
      5     2     3     2     4     5     10 LEFT_ASSIGN TRUE     <-               
      6     2     6     2     6     7      8 NUM_CONST   TRUE     1                
      7     2     6     2     6     8     10 expr        FALSE    1                
      
      

---

    Code
      as.list(parse_text("a <- 1 # inline comment"))
    Output
      $filename
      [1] "<text>"
      
      $code
      $code[[1]]
      a <- 1
      
      
      $srcref
      $srcref[[1]]
      a <- 1
      
      
      $parse_data
      $parse_data[[1]]
      # A tibble: 7 x 9
        line1  col1 line2  col2    id parent token       terminal text            
        <int> <int> <int> <int> <int>  <int> <chr>       <lgl>    <chr>           
      1     1     1     1     6     8      0 expr        FALSE    a <- 1          
      2     1     1     1     1     1      3 SYMBOL      TRUE     a               
      3     1     1     1     1     3      8 expr        FALSE    a               
      4     1     3     1     4     2      8 LEFT_ASSIGN TRUE     <-              
      5     1     6     1     6     4      5 NUM_CONST   TRUE     1               
      6     1     6     1     6     5      8 expr        FALSE    1               
      7     1     8     1    23     6     -8 COMMENT     TRUE     # inline comment
      
      

---

    Code
      as.list(parse_text("a <- 1\n# separate comment"))
    Output
      $filename
      [1] "<text>" "<text>"
      
      $code
      $code[[1]]
      a <- 1
      
      $code[[2]]
      <zap>
      
      
      $srcref
      $srcref[[1]]
      a <- 1
      
      $srcref[[2]]
      <zap>
      
      
      $parse_data
      $parse_data[[1]]
      # A tibble: 6 x 9
        line1  col1 line2  col2    id parent token       terminal text  
        <int> <int> <int> <int> <int>  <int> <chr>       <lgl>    <chr> 
      1     1     1     1     6     7      0 expr        FALSE    a <- 1
      2     1     1     1     1     1      3 SYMBOL      TRUE     a     
      3     1     1     1     1     3      7 expr        FALSE    a     
      4     1     3     1     4     2      7 LEFT_ASSIGN TRUE     <-    
      5     1     6     1     6     4      5 NUM_CONST   TRUE     1     
      6     1     6     1     6     5      7 expr        FALSE    1     
      
      $parse_data[[2]]
      # A tibble: 1 x 9
        line1  col1 line2  col2    id parent token   terminal text              
        <int> <int> <int> <int> <int>  <int> <chr>   <lgl>    <chr>             
      1     2     1     2    18    10      0 COMMENT TRUE     # separate comment
      
      

---

    Code
      as.list(parse_text("a <- 1\n#comment\n\n#comment"))
    Output
      $filename
      [1] "<text>" "<text>" "<text>"
      
      $code
      $code[[1]]
      a <- 1
      
      $code[[2]]
      <zap>
      
      $code[[3]]
      <zap>
      
      
      $srcref
      $srcref[[1]]
      a <- 1
      
      $srcref[[2]]
      <zap>
      
      $srcref[[3]]
      <zap>
      
      
      $parse_data
      $parse_data[[1]]
      # A tibble: 6 x 9
        line1  col1 line2  col2    id parent token       terminal text  
        <int> <int> <int> <int> <int>  <int> <chr>       <lgl>    <chr> 
      1     1     1     1     6     7      0 expr        FALSE    a <- 1
      2     1     1     1     1     1      3 SYMBOL      TRUE     a     
      3     1     1     1     1     3      7 expr        FALSE    a     
      4     1     3     1     4     2      7 LEFT_ASSIGN TRUE     <-    
      5     1     6     1     6     4      5 NUM_CONST   TRUE     1     
      6     1     6     1     6     5      7 expr        FALSE    1     
      
      $parse_data[[2]]
      # A tibble: 1 x 9
        line1  col1 line2  col2    id parent token   terminal text    
        <int> <int> <int> <int> <int>  <int> <chr>   <lgl>    <chr>   
      1     2     1     2     8    10      0 COMMENT TRUE     #comment
      
      $parse_data[[3]]
      # A tibble: 1 x 9
        line1  col1 line2  col2    id parent token   terminal text    
        <int> <int> <int> <int> <int>  <int> <chr>   <lgl>    <chr>   
      1     4     1     4     8    15      0 COMMENT TRUE     #comment
      
      

---

    Code
      as.list(parse_text("a <- 1\na <- 2"))
    Output
      $filename
      [1] "<text>" "<text>"
      
      $code
      $code[[1]]
      a <- 1
      
      $code[[2]]
      a <- 2
      
      
      $srcref
      $srcref[[1]]
      a <- 1
      
      $srcref[[2]]
      a <- 2
      
      
      $parse_data
      $parse_data[[1]]
      # A tibble: 6 x 9
        line1  col1 line2  col2    id parent token       terminal text  
        <int> <int> <int> <int> <int>  <int> <chr>       <lgl>    <chr> 
      1     1     1     1     6     7      0 expr        FALSE    a <- 1
      2     1     1     1     1     1      3 SYMBOL      TRUE     a     
      3     1     1     1     1     3      7 expr        FALSE    a     
      4     1     3     1     4     2      7 LEFT_ASSIGN TRUE     <-    
      5     1     6     1     6     4      5 NUM_CONST   TRUE     1     
      6     1     6     1     6     5      7 expr        FALSE    1     
      
      $parse_data[[2]]
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
      $filename
      [1] "<text>" "<text>"
      
      $code
      $code[[1]]
      a <- 1
      
      $code[[2]]
      a <- 2
      
      
      $srcref
      $srcref[[1]]
      a <- 1
      
      $srcref[[2]]
      a <- 2
      
      
      $parse_data
      $parse_data[[1]]
      # A tibble: 6 x 9
        line1  col1 line2  col2    id parent token       terminal text  
        <int> <int> <int> <int> <int>  <int> <chr>       <lgl>    <chr> 
      1     1     1     1     6     7      0 expr        FALSE    a <- 1
      2     1     1     1     1     1      3 SYMBOL      TRUE     a     
      3     1     1     1     1     3      7 expr        FALSE    a     
      4     1     3     1     4     2      7 LEFT_ASSIGN TRUE     <-    
      5     1     6     1     6     4      5 NUM_CONST   TRUE     1     
      6     1     6     1     6     5      7 expr        FALSE    1     
      
      $parse_data[[2]]
      # A tibble: 6 x 9
        line1  col1 line2  col2    id parent token       terminal text  
        <int> <int> <int> <int> <int>  <int> <chr>       <lgl>    <chr> 
      1     1     9     1    14    16      0 expr        FALSE    a <- 2
      2     1     9     1     9    10     12 SYMBOL      TRUE     a     
      3     1     9     1     9    12     16 expr        FALSE    a     
      4     1    11     1    12    11     16 LEFT_ASSIGN TRUE     <-    
      5     1    14     1    14    13     14 NUM_CONST   TRUE     2     
      6     1    14     1    14    14     16 expr        FALSE    2     
      
      

