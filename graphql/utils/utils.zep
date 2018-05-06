namespace GraphQL\Utils;

use GraphQL\Error\Error;
use GraphQL\Error\InvariantViolation;
use GraphQL\Error\Warning;
use GraphQL\Language\AST\Node;
use GraphQL\Type\Definition\Type;
use GraphQL\Type\Definition\WrappingType;
use Traversable, InvalidArgumentException;
class Utils
{
    public static function undefined()
    {
        var undefined;
    
        
        let undefined =  new \stdClass();
        return  undefined ? undefined : undefined;
    }
    
    /**
     * Check if the value is invalid
     *
     * @param mixed $value
     * @return bool
     */
    public static function isInvalid(value) -> bool
    {
        return self::undefined() === value;
    }
    
    /**
     * @param object $obj
     * @param array  $vars
     * @param array  $requiredKeys
     *
     * @return object
     */
    public static function assign(obj, array vars, array requiredKeys = [])
    {
        var key, value, cls;
    
        for key in requiredKeys {
            if !(isset vars[key]) {
                throw new InvalidArgumentException("Key {key} is expected to be set and not to be null");
            }
        }
        for key, value in vars {
            if !(property_exists(obj, key)) {
                let cls =  get_class(obj);
                Warning::warn("Trying to set non-existing property '{key}' on class '{cls}'", Warning::WARNING_ASSIGN);
            }
            let obj->{key} = value;
        }
        return obj;
    }
    
    /**
     * @param array|Traversable $traversable
     * @param callable $predicate
     * @return null
     */
    public static function find(traversable, predicate) -> null
    {
        var key, value;
    
        self::invariant(is_array(traversable) || traversable instanceof \Traversable, __METHOD__ . " expects array or Traversable");
        for key, value in traversable {
            if {predicate}(value, key) {
                return value;
            }
        }
        return null;
    }
    
    /**
     * @param $traversable
     * @param callable $predicate
     * @return array
     * @throws \Exception
     */
    public static function filter(traversable, predicate) -> array
    {
        var result, assoc, key, value;
    
        self::invariant(is_array(traversable) || traversable instanceof \Traversable, __METHOD__ . " expects array or Traversable");
        let result =  [];
        let assoc =  false;
        for key, value in traversable {
            if !(assoc) && !(is_int(key)) {
                let assoc =  true;
            }
            if {predicate}(value, key) {
                let result[key] = value;
            }
        }
        return  assoc ? result  : array_values(result);
    }
    
    /**
     * @param array|\Traversable $traversable
     * @param callable $fn function($value, $key) => $newValue
     * @return array
     * @throws \Exception
     */
    public static function map(traversable, fn) -> array
    {
        var map, key, value;
    
        self::invariant(is_array(traversable) || traversable instanceof \Traversable, __METHOD__ . " expects array or Traversable");
        let map =  [];
        for key, value in traversable {
            let map[key] =  {fn}(value, key);
        }
        return map;
    }
    
    /**
     * @param $traversable
     * @param callable $fn
     * @return array
     * @throws \Exception
     */
    public static function mapKeyValue(traversable, fn) -> array
    {
        var map, key, value, newKey, newValue, tmpListNewKeyNewValue;
    
        self::invariant(is_array(traversable) || traversable instanceof \Traversable, __METHOD__ . " expects array or Traversable");
        let map =  [];
        for key, value in traversable {
            let tmpListNewKeyNewValue = {fn}(value, key);
            let newKey = tmpListNewKeyNewValue[0];
            let newValue = tmpListNewKeyNewValue[1];
            let map[newKey] = newValue;
        }
        return map;
    }
    
    /**
     * @param $traversable
     * @param callable $keyFn function($value, $key) => $newKey
     * @return array
     * @throws \Exception
     */
    public static function keyMap(traversable, keyFn) -> array
    {
        var map, key, value, newKey;
    
        self::invariant(is_array(traversable) || traversable instanceof \Traversable, __METHOD__ . " expects array or Traversable");
        let map =  [];
        for key, value in traversable {
            let newKey =  {keyFn}(value, key);
            if is_scalar(newKey) {
                let map[newKey] = value;
            }
        }
        return map;
    }
    
    /**
     * @param $traversable
     * @param callable $fn
     */
    public static function each(traversable, fn) -> void
    {
        var key, item;
    
        self::invariant(is_array(traversable) || traversable instanceof \Traversable, __METHOD__ . " expects array or Traversable");
        for key, item in traversable {
            {fn}(item, key);
        }
    }
    
    /**
     * Splits original traversable to several arrays with keys equal to $keyFn return
     *
     * E.g. Utils::groupBy([1, 2, 3, 4, 5], function($value) {return $value % 3}) will output:
     * [
     *    1 => [1, 4],
     *    2 => [2, 5],
     *    0 => [3],
     * ]
     *
     * $keyFn is also allowed to return array of keys. Then value will be added to all arrays with given keys
     *
     * @param $traversable
     * @param callable $keyFn function($value, $key) => $newKey(s)
     * @return array
     */
    public static function groupBy(traversable, keyFn) -> array
    {
        var grouped, key, value, newKeys;
    
        self::invariant(is_array(traversable) || traversable instanceof \Traversable, __METHOD__ . " expects array or Traversable");
        let grouped =  [];
        for key, value in traversable {
            let newKeys =  (array) {keyFn}(value, key);
            for key in newKeys {
                let grouped[key][] = value;
            }
        }
        return grouped;
    }
    
    /**
     * @param array|Traversable $traversable
     * @param callable $keyFn
     * @param callable $valFn
     * @return array
     */
    public static function keyValMap(traversable, keyFn, valFn) -> array
    {
        var map, item;
    
        let map =  [];
        for item in traversable {
            let map[{keyFn}(item)] =  {valFn}(item);
        }
        return map;
    }
    
    /**
     * @param $traversable
     * @param callable $predicate
     * @return bool
     */
    public static function every(traversable, predicate) -> bool
    {
        var key, value;
    
        for key, value in traversable {
            if !({predicate}(value, key)) {
                return false;
            }
        }
        return true;
    }
    
    /**
     * @param $test
     * @param string $message
     * @param mixed $sprintfParam1
     * @param mixed $sprintfParam2 ...
     * @throws Error
     */
    public static function invariant(test, string message = "") -> void
    {
        var args;
    
        if !(test) {
            if func_num_args() > 2 {
                let args =  func_get_args();
                array_shift(args);
                let message =  call_user_func_array("sprintf", args);
            }
            // TODO switch to Error here
            throw new InvariantViolation(message);
        }
    }
    
    /**
     * @param $var
     * @return string
     */
    public static function getVariableType(varr) -> string
    {
        if varr instanceof Type {
            // FIXME: Replace with schema printer call
            if varr instanceof WrappingType {
                let varr =  varr->getWrappedType(true);
            }
            return varr->name;
        }
        return  is_object(varr) ? get_class(varr)  : gettype(varr);
    }
    
    /**
     * @param mixed $var
     * @return string
     */
    public static function printSafeJson(varr) -> string
    {
        if varr instanceof \stdClass {
            let varr =  (array) varr;
        }
        if is_array(varr) {
            return json_encode(varr);
        }
        if varr === "" {
            return "(empty string)";
        }
        if varr === null {
            return "null";
        }
        if varr === false {
            return "false";
        }
        if varr === true {
            return "true";
        }
        if is_string(varr) {
            return "\"{varr}\"";
        }
        if is_scalar(varr) {
            return (string) varr;
        }
        return gettype(varr);
    }
    
    /**
     * @param $var
     * @return string
     */
    public static function printSafe(varr) -> string
    {
        if varr instanceof Type {
            return varr->toString();
        }
        if is_object(varr) {
            if method_exists(varr, "__toString") {
                return (string) varr;
            } else {
                return "instance of " . get_class(varr);
            }
        }
        if is_array(varr) {
            return json_encode(varr);
        }
        if varr === "" {
            return "(empty string)";
        }
        if varr === null {
            return "null";
        }
        if varr === false {
            return "false";
        }
        if varr === true {
            return "true";
        }
        if is_string(varr) {
            return varr;
        }
        if is_scalar(varr) {
            return (string) varr;
        }
        return gettype(varr);
    }
    
    /**
     * UTF-8 compatible chr()
     *
     * @param string $ord
     * @param string $encoding
     * @return string
     */
    public static function chr(string ord, string encoding = "UTF-8") -> string
    {
        if ord <= 255 {
            return chr(ord);
        }
        if encoding === "UCS-4BE" {
            return pack("N", ord);
        } else {
            return mb_convert_encoding(self::chr(ord, "UCS-4BE"), encoding, "UCS-4BE");
        }
    }
    
    /**
     * UTF-8 compatible ord()
     *
     * @param string $char
     * @param string $encoding
     * @return mixed
     */
    public static function ord(string char, string encoding = "UTF-8")
    {
        var ord, tmpListOrd;
    
        if !(char) && char !== "0" {
            return 0;
        }
        if !(isset char[1]) {
            return ord(char);
        }
        if encoding !== "UCS-4BE" {
            let char =  mb_convert_encoding(char, "UCS-4BE", encoding);
        }
        ;
        let tmpListOrd = unpack("N", char);
        ;
        let ord = tmpListOrd[1];
        return ord;
    }
    
    /**
     * Returns UTF-8 char code at given $positing of the $string
     *
     * @param $string
     * @param $position
     * @return mixed
     */
    public static function charCodeAt(stringg, position)
    {
        var char;
    
        let char =  mb_substr(stringg, position, 1, "UTF-8");
        return self::ord(char);
    }
    
    /**
     * @param $code
     * @return string
     */
    public static function printCharCode(code) -> string
    {
        if code === null {
            return "<EOF>";
        }
        return  code < 127 ? json_encode(Utils::chr(code))  : "\"\\u" . dechex(code) . "\"";
    }
    
    /**
     * Upholds the spec rules about naming.
     *
     * @param $name
     * @throws Error
     */
    public static function assertValidName(name) -> void
    {
        var error;
    
        let error =  self::isValidNameError(name);
        if error {
            throw error;
        }
    }
    
    /**
     * Returns an Error if a name is invalid.
     *
     * @param string $name
     * @param Node|null $node
     * @return Error|null
     */
    public static function isValidNameError(string name, node = null)
    {
        Utils::invariant(is_string(name), "Expected string");
        if isset name[1] && name[0] === "_" && name[1] === "_" {
            return new Error("Name \"{name}\" must not begin with \"__\", which is reserved by " . "GraphQL introspection.", node);
        }
        if !(preg_match("/^[_a-zA-Z][_a-zA-Z0-9]*$/", name)) {
            return new Error("Names must match /^[_a-zA-Z][_a-zA-Z0-9]*\$/ but \"{name}\" does not.", node);
        }
        return null;
    }
    
    /**
     * Wraps original closure with PHP error handling (using set_error_handler).
     * Resulting closure will collect all PHP errors that occur during the call in $errors array.
     *
     * @param callable $fn
     * @param \ErrorException[] $errors
     * @return \Closure
     */
    public static function withErrorHandling(fn, array errors) -> <\Closure>
    {
        let errors[] = new \ErrorException(message, 0, severity, file, line);
        return new UtilswithErrorHandlingClosureOne(fn, errors);
    }
    
    /**
     * @param string[] $items
     * @return string
     */
    public static function quotedOrList(array items) -> string
    {
        let items =  array_map(new UtilsquotedOrListClosureOne(), items);
        return self::orList(items);
    }
    
    public static function orList(array items)
    {
        var selected, selectedLength, firstSelected;
    
        if !(items) {
            throw new \LogicException("items must not need to be empty.");
        }
        let selected =  array_slice(items, 0, 5);
        let selectedLength =  count(selected);
        let firstSelected = selected[0];
        if selectedLength === 1 {
            return firstSelected;
        }
        return array_reduce(range(1, selectedLength - 1), new UtilsorListClosureOne(selected, selectedLength), firstSelected);
    }
    
    /**
     * Given an invalid input string and a list of valid options, returns a filtered
     * list of valid options sorted based on their similarity with the input.
     *
     * Includes a custom alteration from Damerau-Levenshtein to treat case changes
     * as a single edit which helps identify mis-cased values with an edit distance
     * of 1
     * @param string $input
     * @param array $options
     * @return string[]
     */
    public static function suggestionList(string input, array options) -> array
    {
        var optionsByDistance, inputThreshold, option, distance, threshold;
    
        let optionsByDistance =  [];
        let inputThreshold =  mb_strlen(input) / 2;
        for option in options {
            let distance =  input === option ? 0  : ( strtolower(input) === strtolower(option) ? 1  : levenshtein(input, option));
            let threshold =  max(inputThreshold, mb_strlen(option) / 2, 1);
            if distance <= threshold {
                let optionsByDistance[option] = distance;
            }
        }
        asort(optionsByDistance);
        return array_keys(optionsByDistance);
    }

}