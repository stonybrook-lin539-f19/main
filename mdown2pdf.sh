#!/usr/bin/env sh

projectroot="${HOME}/Latex/School/lin539"
mycommands="${projectroot}/templates/mycommands.mdown"
mypackages="${projectroot}/templates/environments.sty"
yaml="${projectroot}/templates/format.yaml"
source="$1"

# preprocess mycommands
tmpcommands="$(mktemp tmpcommandsXXXXXXXX.tmp.sty)"
# delete line-initial and line-final $
sed 's/\(^\$\|\$$\)//g' "$mycommands" > "$tmpcommands"

# regex substitutions in source file
tmpsource="$(mktemp "${source}XXXXXX.tmp")"
cp "$source" "$tmpsource"
# remove underscore from \input_{small,mid,large};
# this is needed to avoid Latex complaints
sed -i 's/\\input_[^{]*{\([^}]*\)}/\\begin{center}\\input{\1}\\end{center}/g' "$tmpsource"
# replace <i>
sed -i 's/<\/i>/\x00/g' "$tmpsource"  # replace by NUL for single character match of end
sed -i 's/<i>\([^\x00]*\)\x00/\\emph{\1}/g' "$tmpsource"  # replace <i>X</i> by \emph{X}
# replace <b>
sed -i 's/<\/b>/\x00/g' "$tmpsource"  # replace by NUL for single character match of end
sed -i 's/<b>\([^\x00]*\)\x00/\\textbf{\1}/g' "$tmpsource" # replace <b>X</b> by \textbf{X}
# replace HTML lists by Latex
sed -i 's/<ul>/\\begin{itemize}/g' "$tmpsource"
sed -i 's/<\/ul>/\\end{itemize}/g' "$tmpsource"
sed -i 's/<ol>/\\begin{enumerate}/g' "$tmpsource"
sed -i 's/<\/ol>/\\end{enumerate}/g' "$tmpsource"
sed -i 's/<\/li>/\x00/g' "$tmpsource"  # replace by NUL for single character match of end
sed -i 's/<li>\([^\x00]*\)\x00/\\item \1/g' "$tmpsource"
# delete all <br> and <br />
sed -i 's/<br\s*\/\?>//g' "$tmpsource"

# convert with pandoc
# cp "$tmpsource" tmpfile
tex="$(basename "$source" .mdown).tex"
pdf="$(basename "$source" .mdown).pdf"
pandoc "$tmpsource" -t latex --standalone --metadata-file="$yaml" -H "$mypackages" -H "$tmpcommands" -o "$tex"
latexmk -pdf "$tex"
latexmk -c

# remove temporary files
rm "$tex" 2> /dev/null
rm "$tmpcommands" 2> /dev/null
rm "$tmpsource" 2> /dev/null
