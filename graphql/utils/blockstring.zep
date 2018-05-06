namespace GraphQL\Utils;

class BlockString
{
    /**
     * Produces the value of a block string from its parsed raw value, similar to
     * Coffeescript's block string, Python's docstring trim or Ruby's strip_heredoc.
     *
     * This implements the GraphQL spec's BlockStringValue() static algorithm.
     */
    public static function value(rawString)
    {
        var lines, commonIndent, linesLength, i, line, indent;
    
        // Expand a block string's raw value into independent lines.
        let lines =  preg_split("/\\r\\n|[\\n\\r]/", rawString);
        // Remove common indentation from all lines but first.
        let commonIndent =  null;
        let linesLength =  count(lines);
        let i = 1;
        for i in range(1, linesLength) {
            let line = lines[i];
            let indent =  self::leadingWhitespace(line);
            if indent < mb_strlen(line) && (commonIndent === null || indent < commonIndent) {
                let commonIndent = indent;
                if commonIndent === 0 {
                    break;
                }
            }
        }
        if commonIndent {
            let i = 1;
            for i in range(1, linesLength) {
                let line = lines[i];
                let lines[i] =  mb_substr(line, commonIndent);
            }
        }
        // Remove leading and trailing blank lines.
        while (count(lines) > 0 && trim(lines[0], " 	") === "") {
            array_shift(lines);
        }
        while (count(lines) > 0 && trim(lines[count(lines) - 1], " 	") === "") {
            array_pop(lines);
        }
        // Return a string of the lines joined with U+000A.
        return implode("
", lines);
    }
    
    protected static function leadingWhitespace(str)
    {
        var i;
    
        let i = 0;
        while (i < mb_strlen(str) && (str[i] === " " || str[i] === "\\t")) {
            let i++;
        }
        return i;
    }

}