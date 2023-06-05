find test -type d | while IFS= read -r d; do 
    echo $d
    clang-format -style="{ColumnLimit: 100}" -i $d/*.c
done

find example/* -type d | while IFS= read -r d; do
    echo $d
    clang-format -style="{ColumnLimit: 100}" -i $d/*.c
done
