ipset_list
==========

ipset set listing wrapper script


Features:
==========
(in addition to the native ipset options)

- Calculate sum of set members (and match on that count).
- List only members of a specified set.
- Choose a delimiter character for separating members.
- Show only sets containing a specific (glob matching) header.
- Arithmetic comparison on headers with an integer value.
- Match members using a globbing or regex pattern.
- Supress listing of (glob matching) headers.
- Supress listing of members matching a glob or regex pattern.
- Calculate the total size in memory of all matching sets.
- Calculate the total amount of all matching and traversed sets.
- Colorize the output.
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
- `ipset_list -Fh Type:hash:ip -Fh "Header:family inet *"` - show all set names, which are of type hash:ip and header of ipv4.
- `ipset_list -Fi References:0`    - show all sets with 0 references
- `ipset_list -Hr 0`               - shortcut for -Fi References:0
- `ipset_list -Ht "!(hash:ip)"`    - show sets which are not of type hash:ip
- `ipset_list -Ht "!(bitmap:*)"`   - show sets wich are not of any bitmap type
- `ipset_list -Mc 0`               - show sets with zero members 
- `ipset_list -Mc '>=100'`         - show sets with a member count greater or equal to 100
- `ipset_list -Hr 2 -Hv 0 -Hs \>10000 -Ht hash:ip`    - find sets with 2 references, revision of 0,
size in memory greater than 10000 and of type hash:ip
- `ipset_list -t -Xh "Revision:*" -Xh "References:*"` - show all sets headers, but exclude Revision and References entries.
- `ipset_list -c -m -Xg "210.*" setA` - show members of setA, but supress listing of entries matching the glob pattern "210.*",
 show count of excluded and total members.
- `ipset_list -Tm`                 - calculate total size in memory of all sets.
- `ipset_list -t -Tm -Xh "@(Type|Re*|Header):*"` - show all sets headers, but supress all but name and memsize entry,
 calculate the total memory size of all sets.
- `ipset_list -Cs -Ht "hash:*"`    - find sets of any hash type, calculate their sum.
- `ipset_list -Ts`             - show all set names and total count of sets.
- `ipset_list -c -t -Cs -Ts -Xh "@(Size*|Re*|Header):*" -Ht "!(bitmap:*)"` - find all sets not of any bitmap type, count their members sum, display only the 'Type' header, count amount of matching and traversed sets.
- `ipset_list -Co -c -Ts -Tm`  - show all set names, count their members, count total amount of sets, show total memory usage of all sets, colorize the output
- `ipset_list -m -r -To 0`     - show members of all sets, try to resolve hosts, set the timeout to 0 (effectivly disabling it).


