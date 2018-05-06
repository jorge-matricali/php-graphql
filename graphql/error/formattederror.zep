namespace GraphQL\Error;

use GraphQL\Language\AST\Node;
use GraphQL\Language\Source;
use GraphQL\Language\SourceLocation;
use GraphQL\Type\Definition\Type;
use GraphQL\Type\Definition\WrappingType;
use GraphQL\Utils\Utils;
/**
 * This class is used for [default error formatting](error-handling.md).
 * It converts PHP exceptions to [spec-compliant errors](https://facebook.github.io/graphql/#sec-Errors)
 * and provides tools for error debugging.
 */
class FormattedError
{
    protected static internalErrorMessage = "Internal server error";
    /**
     * Set default error message for internal errors formatted using createFormattedError().
     * This value can be overridden by passing 3rd argument to `createFormattedError()`.
     *
     * @api
     * @param string $msg
     */
    public static function setInternalErrorMessage(string msg) -> void
    {
        let self::internalErrorMessage = msg;
    }
    
    /**
     * Prints a GraphQLError to a string, representing useful location information
     * about the error's position in the source.
     *
     * @param Error $error
     * @return string
     */
    public static function printError(<Error> error) -> string
    {
        var printedLocations, node, source, location, tmpArray720e5d8ea6732ec26cc3bfd3d1ed1452;
    
        let printedLocations =  [];
        if error->nodes {
            /** @var Node $node */
            for node in error->nodes {
                if node->loc {
                    let printedLocations[] = self::highlightSourceAtLocation(node->loc->source, node->loc->source->getLocation(node->loc->start));
                }
            }
        } else {
            if error->getSource() && error->getLocations() {
                let source =  error->getSource();
                for location in error->getLocations() {
                    let printedLocations[] = self::highlightSourceAtLocation(source, location);
                }
            }
        }
        let tmpArray720e5d8ea6732ec26cc3bfd3d1ed1452 = [error->getMessage()];
        return  !(printedLocations) ? error->getMessage()  : join("

", array_merge(tmpArray720e5d8ea6732ec26cc3bfd3d1ed1452, printedLocations)) . "
";
    }
    
    /**
     * Render a helpful description of the location of the error in the GraphQL
     * Source document.
     *
     * @param Source $source
     * @param SourceLocation $location
     * @return string
     */
    protected static function highlightSourceAtLocation(<Source> source, <SourceLocation> location) -> string
    {
        var line, lineOffset, columnOffset, contextLine, contextColumn, prevLineNum, lineNum, nextLineNum, padLen, lines, outputLines;
    
        let line =  location->line;
        let lineOffset =  source->locationOffset->line - 1;
        let columnOffset =  self::getColumnOffset(source, location);
        let contextLine =  line + lineOffset;
        let contextColumn =  location->column + columnOffset;
        let prevLineNum =  (string) (contextLine - 1);
        let lineNum =  (string) contextLine;
        let nextLineNum =  (string) (contextLine + 1);
        let padLen =  strlen(nextLineNum);
        let lines =  preg_split("/\\r\\n|[\\n\\r]/", source->body);
        let lines[0] =  self::whitespace(source->locationOffset->column - 1) . lines[0];
        let outputLines =  ["{source->name} ({contextLine}:{contextColumn})",  line >= 2 ? self::lpad(padLen, prevLineNum) . ": " . lines[line - 2]  : null, self::lpad(padLen, lineNum) . ": " . lines[line - 1], self::whitespace(2 + padLen + contextColumn - 1) . "^",  line < count(lines) ? self::lpad(padLen, nextLineNum) . ": " . lines[line]  : null];
        return join("
", array_filter(outputLines));
    }
    
    /**
     * @param Source $source
     * @param SourceLocation $location
     * @return int
     */
    protected static function getColumnOffset(<Source> source, <SourceLocation> location) -> int
    {
        return  location->line === 1 ? source->locationOffset->column - 1  : 0;
    }
    
    /**
     * @param int $len
     * @return string
     */
    protected static function whitespace(int len) -> string
    {
        return str_repeat(" ", len);
    }
    
    /**
     * @param int $len
     * @return string
     */
    protected static function lpad(int len, str) -> string
    {
        return self::whitespace(len - mb_strlen(str)) . str;
    }
    
    /**
     * Standard GraphQL error formatter. Converts any exception to array
     * conforming to GraphQL spec.
     *
     * This method only exposes exception message when exception implements ClientAware interface
     * (or when debug flags are passed).
     *
     * For a list of available debug flags see GraphQL\Error\Debug constants.
     *
     * @api
     * @param \Throwable $e
     * @param bool|int $debug
     * @param string $internalErrorMessage
     * @return array
     * @throws \Throwable
     */
    public static function createFromException(e, debug = false, string internalErrorMessage = null) -> array
    {
        var formattedError, locations;
    
        Utils::invariant(e instanceof \Exception || e instanceof \Throwable, "Expected exception, got %s", Utils::getVariableType(e));
        let internalErrorMessage =  internalErrorMessage ? internalErrorMessage : self::internalErrorMessage;
        if e instanceof ClientAware {
            let formattedError =  ["message" :  e->isClientSafe() ? e->getMessage()  : internalErrorMessage, "category" : e->getCategory()];
        } else {
            let formattedError =  ["message" : internalErrorMessage, "category" : Error::CATEGORY_INTERNAL];
        }
        if e instanceof Error {
            if e->getExtensions() {
                let formattedError =  array_merge(e->getExtensions(), formattedError);
            }
            let locations =  Utils::map(e->getLocations(), new FormattedErrorcreateFromExceptionClosureOne());
            if !(empty(locations)) {
                let formattedError["locations"] = locations;
            }
            if !(empty(e->path)) {
                let formattedError["path"] = e->path;
            }
        }
        if debug {
            let formattedError =  self::addDebugEntries(formattedError, e, debug);
        }
        return formattedError;
    }
    
    /**
     * Decorates spec-compliant $formattedError with debug entries according to $debug flags
     * (see GraphQL\Error\Debug for available flags)
     *
     * @param array $formattedError
     * @param \Throwable $e
     * @param bool $debug
     * @return array
     * @throws \Throwable
     */
    public static function addDebugEntries(array formattedError, e, bool debug) -> array
    {
        var isInternal, isTrivial, debugging;
    
        if !(debug) {
            return formattedError;
        }
        Utils::invariant(e instanceof \Exception || e instanceof \Throwable, "Expected exception, got %s", Utils::getVariableType(e));
        let debug =  (int) debug;
        if debug & Debug::RETHROW_INTERNAL_EXCEPTIONS {
            if !(e instanceof Error) {
                throw e;
            } else {
                if e->getPrevious() {
                    throw e->getPrevious();
                }
            }
        }
        let isInternal =  !(e instanceof ClientAware) || !(e->isClientSafe());
        if debug & Debug::INCLUDE_DEBUG_MESSAGE && isInternal {
            // Displaying debugMessage as a first entry:
            let formattedError =  ["debugMessage" : e->getMessage()] + formattedError;
        }
        if debug & Debug::INCLUDE_TRACE {
            if e instanceof \ErrorException || e instanceof \Error {
                let formattedError = this->array_plus(formattedError, ["file" : e->getFile(), "line" : e->getLine()]);
            }
            let isTrivial =  e instanceof Error && !(e->getPrevious());
            if !(isTrivial) {
                let debugging =  e->getPrevious() ? e->getPrevious() : e;
                let formattedError["trace"] = static::toSafeTrace(debugging);
            }
        }
        return formattedError;
    }
    
    /**
     * Prepares final error formatter taking in account $debug flags.
     * If initial formatter is not set, FormattedError::createFromException is used
     *
     * @param callable|null $formatter
     * @param $debug
     * @return callable|\Closure
     */
    public static function prepareFormatter(formatter = null, debug)
    {
        let formatter =  formatter ? formatter : new FormattedErrorprepareFormatterClosureOne();
        if debug {
            let formatter =  new FormattedErrorprepareFormatterClosureOne(formatter, debug);
        }
        return formatter;
    }
    
    /**
     * Returns error trace as serializable array
     *
     * @api
     * @param \Throwable $error
     * @return array
     */
    public static function toSafeTrace(error) -> array
    {
        var trace, safeErr, tmpArray5d970e6e9fefec06167bb720ecb8fe57, func, args, tmpArraye1e37e62ecde3b1a6c804729ee73ca2c, funcStr;
    
        let trace =  error->getTrace();
        // Remove invariant entries as they don't provide much value:
        if isset trace[0]["function"] && isset trace[0]["class"] && trace[0]["class"] . "::" . trace[0]["function"] === "GraphQL\\Utils\\Utils::invariant" {
            array_shift(trace);
        } else {
            if !(isset trace[0]["file"]) {
                array_shift(trace);
            }
        }
        let tmpArray5d970e6e9fefec06167bb720ecb8fe57 = ["file" : true, "line" : true];
        let safeErr =  array_intersect_key(err, tmpArray5d970e6e9fefec06167bb720ecb8fe57);
        let func = err["function"];
        let args =  !(empty(err["args"])) ? let tmpArraye1e37e62ecde3b1a6c804729ee73ca2c = [__CLASS__, "printVar"];
        array_map(tmpArraye1e37e62ecde3b1a6c804729ee73ca2c, err["args"])  : [];
        let funcStr =  func . "(" . implode(", ", args);
        let safeErr["call"] =  err["class"] . "::";
        let safeErr["function"] = funcStr;
        return array_map(new FormattedErrortoSafeTraceClosureOne(), trace);
    }
    
    /**
     * @param $var
     * @return string
     */
    public static function printVar(varr) -> string
    {
        if varr instanceof Type {
            // FIXME: Replace with schema printer call
            if varr instanceof WrappingType {
                let varr =  varr->getWrappedType(true);
            }
            return "GraphQLType: " . varr->name;
        }
        if is_object(varr) {
            return "instance of " . get_class(varr) . ( varr instanceof \Countable ? "(" . count(varr) . ")"  : "");
        }
        if is_array(varr) {
            return "array(" . count(varr) . ")";
        }
        if varr === "" {
            return "(empty string)";
        }
        if is_string(varr) {
            return "'" . addcslashes(varr, "'") . "'";
        }
        if is_bool(varr) {
            return  varr ? "true"  : "false";
        }
        if is_scalar(varr) {
            return varr;
        }
        if varr === null {
            return "null";
        }
        return gettype(varr);
    }
    
    /**
     * @deprecated as of v0.8.0
     * @param $error
     * @param SourceLocation[] $locations
     * @return array
     */
    public static function create(error, array locations = []) -> array
    {
        var formatted;
    
        let formatted =  ["message" : error];
        if !(empty(locations)) {
            let formatted["locations"] =  array_map(new FormattedErrorcreateClosureOne(), locations);
        }
        return formatted;
    }
    
    /**
     * @param \ErrorException $e
     * @deprecated as of v0.10.0, use general purpose method createFromException() instead
     * @return array
     */
    public static function createFromPHPError(<ErrorException> e) -> array
    {
        var tmpArray5731680e53210832fd5bd3f23fc5d6b1;
    
        let tmpArray5731680e53210832fd5bd3f23fc5d6b1 = ["message" : e->getMessage(), "severity" : e->getSeverity(), "trace" : self::toSafeTrace(e)];
        return tmpArray5731680e53210832fd5bd3f23fc5d6b1;
    }

    private function array_plus(array1, array2)
    {
        var union, key, value;
        let union = array1;
        for key, value in array2 {
            if false === array_key_exists(key, union) {
                let union[key] = value;
            }
        }
        
        return union;
    }
}