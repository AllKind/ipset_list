ipset_list
==========

ipset set listing wrapper script


Features (in addition to the native ipset options):
==========

- Calculate sum of set members.
- Supress listing of headers.
- List only members of a specified set.
- Choose a delimiter character for separating members.
- Match entries using a globbing or regex pattern.
- Operate on a single, selected, or all sets.


Examples:
==========

- $0                        - no args, just list set names
- $0 -c                     - show all set names and their member sum
- $0 -t                     - show all sets, but headers only
- $0 -c -t setA             - show headers and member sum of setA
- $0 -i setA                - show only members entries of setA
- $0 -c -m setA setB        - show members and sum of setA & setB
- $0 -a -c -d :             - show all sets members, sum and use `:' as entry delimiter
- $0 -a -c setA             - show all info of setA and its members sum
- $0 -c -m -d $'\n' setA    - show members and sum of setA, delim with newline
- $0 -c -m -r -s setA       - show members resolved and sorted + sum of setA
- $0 -i -Fr "^210\..*" setA - show only members of setA matching the regex "^210\..*"

