ipset_list
==========

ipset set listing wrapper script


Features (in addition to the native ipset options):
==========

- Calculate sum of set members.
- Supress listing of headers.
- List only members of a specified set.
- Choose a delimiter character for separating members.
- Show only set containing a specific (glob matching) header.
- Match entries using a globbing or regex pattern.
- Operate on a single, selected, or all sets.


Examples:
==========

- `ipset_list`                         - no args, just list set names
- `ipset_list -c`                      - show all set names and their member sum
- `ipset_list -t`                      - show all sets, but headers only
- `ipset_list -c -t setA`              - show headers and member sum of setA
- `ipset_list -i setA`                 - show only members entries of setA
- `ipset_list -c -m setA setB`         - show members and sum of setA & setB
- `ipset_list -a -c -d :`              - show all sets members, sum and use `:' as entry delimiter
- `ipset_list -a -c setA`              - show all info of setA and its members sum
- `ipset_list -c -m -d $'\n' setA`     - show members and sum of setA, delim with newline
- `ipset_list -c -m -r -s setA`        - show members resolved and sorted + sum of setA
- `ipset_list -i -Fr "^210\..*" setA` - show only members of setA matching the regex "^210\\..*"
- `ipset_list -a -c -Fh  "Type:hash:ip"  -Fr "^210\..*"` - show all information of sets with type hash:ip, 
matching the regex "^210\\..*", show match and members sum


