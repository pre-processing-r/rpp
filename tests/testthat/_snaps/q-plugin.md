# snapshots

    Code
      writeLines(q_elide("?function(a = 0L) {}"))
    Output
      ?function(a = 0L) {}

---

    Code
      writeLines(q_elide("?function(a = ?Integer()) {}"))
    Output
      ?function(a = Integer()) {} # !q ?function(a = ?Integer()) {}

---

    Code
      writeLines(q_elide("?function(a = 0L?Integer()) {}"))
    Output
      ?function(a = Integer()) {} # !q ?function(a = 0L?Integer()) {}

