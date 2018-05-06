namespace GraphQL\Type\Definition;

use GraphQL\Error\InvariantViolation;
use GraphQL\Error\Warning;
use GraphQL\Utils\Utils;
/**
 * Class Config
 * @package GraphQL\Type\Definition
 * @deprecated See https://github.com/webonyx/graphql-php/issues/148 for alternatives
 */
class Config
{
    const BOOLEAN = 1;
    const STRING = 2;
    const INT = 4;
    const FLOAT = 8;
    const NUMERIC = 16;
    const SCALAR = 32;
    const CALLBACK = 64;
    const ANY = 128;
    const NAME = 256;
    const OUTPUT_TYPE = 2048;
    const INPUT_TYPE = 4096;
    const INTERFACE_TYPE = 8192;
    const OBJECT_TYPE = 16384;
    const REQUIRED = 65536;
    const KEY_AS_NAME = 131072;
    const MAYBE_THUNK = 262144;
    const MAYBE_TYPE = 524288;
    const MAYBE_NAME = 1048576;
    /**
     * @var bool
     */
    protected static enableValidation = false;
    /**
     * @var bool
     */
    protected static allowCustomOptions = true;
    /**
     *
     * Disables config validation
     *
     * @deprecated See https://github.com/webonyx/graphql-php/issues/148 for alternatives
     */
    public static function disableValidation() -> void
    {
        let self::enableValidation =  false;
    }
    
    /**
     * Enable deep config validation (disabled by default because it creates significant performance overhead).
     * Useful only at development to catch type definition errors quickly.
     *
     * @deprecated See https://github.com/webonyx/graphql-php/issues/148 for alternatives
     */
    public static function enableValidation(allowCustomOptions = true) -> void
    {
        Warning::warnOnce("GraphQL\\Type\\Defintion\\Config is deprecated and will be removed in the next version. " . "See https://github.com/webonyx/graphql-php/issues/148 for alternatives", Warning::WARNING_CONFIG_DEPRECATION, E_USER_DEPRECATED);
        let self::enableValidation =  true;
        let self::allowCustomOptions = allowCustomOptions;
    }
    
    /**
     * @return bool
     */
    public static function isValidationEnabled() -> bool
    {
        return self::enableValidation;
    }
    
    /**
     * @param array $config
     * @param array $definition
     */
    public static function validate(array config, array definition) -> void
    {
        var name;
    
        if self::enableValidation {
            let name =  isset config["name"] ? config["name"]  : "(Unnamed Type)";
            self::validateMap(name, config, definition);
        }
    }
    
    /**
     * @param $typeName
     * @param array $config
     * @param array $definition
     */
    public static function validateField(typeName, array config, array definition) -> void
    {
        var pathStr;
    
        if self::enableValidation {
            if !(isset config["name"]) {
                let pathStr =  isset config["type"] ? "(Unknown Field of type: " . Utils::printSafe(config["type"]) . ")"  : "(Unknown Field)";
            } else {
                let pathStr = "";
            }
            self::validateMap( typeName ? typeName : "(Unnamed Type)", config, definition, pathStr);
        }
    }
    
    /**
     * @param array|int $definition
     * @param int $flags
     * @return \stdClass
     */
    public static function arrayOf(definition, int flags = 0) -> <\stdClass>
    {
        var tmp;
    
        let tmp =  new \stdClass();
        let tmp->isArray =  true;
        let tmp->definition = definition;
        let tmp->flags =  (int) flags;
        return tmp;
    }
    
    /**
     * @param $typeName
     * @param array $map
     * @param array $definitions
     * @param null $pathStr
     */
    protected static function validateMap(typeName, array map, array definitions, null pathStr = null)
    {
        var suffix, unexpectedKeys, requiredKeys, missingKeys, key, value;
    
        let suffix =  pathStr ? " at {pathStr}"  : "";
        // Make sure there are no unexpected keys in map
        let unexpectedKeys =  array_keys(array_diff_key(map, definitions));
        if !(empty(unexpectedKeys)) {
            if !(self::allowCustomOptions) {
                Warning::warnOnce(sprintf("Error in \"%s\" type definition: Non-standard keys \"%s\" " . suffix, typeName, implode(", ", unexpectedKeys)), Warning::WARNING_CONFIG);
            }
            let map =  array_intersect_key(map, definitions);
        }
        // Make sure that all required keys are present in map
        let requiredKeys =  array_filter(definitions, new ConfigvalidateMapClosureOne());
        let missingKeys =  array_keys(array_diff_key(requiredKeys, map));
        Utils::invariant(empty(missingKeys), "Error in \"" . typeName . "\" type definition: Required keys missing: \"%s\" %s", implode(", ", missingKeys), suffix);
        // Make sure that every map value is valid given the definition
        for key, value in map {
            self::validateEntry(typeName, key, value, definitions[key],  pathStr ? "{pathStr}:{key}"  : key);
        }
    }
    
    /**
     * @param $typeName
     * @param $key
     * @param $value
     * @param $def
     * @param $pathStr
     * @throws \Exception
     */
    protected static function validateEntry(typeName, key, value, def, pathStr)
    {
        var type, err, arrKey, arrValue;
    
        let type =  Utils::getVariableType(value);
        let err =  "Error in \"" . typeName . "\" type definition: expecting \"%s\" at \"" . pathStr . "\", but got \"" . type . "\"";
        if def instanceof \stdClass {
            if (def->flags & self::REQUIRED) === 0 && value === null {
                return;
            }
            if (def->flags & self::MAYBE_THUNK) > 0 {
                // TODO: consider wrapping thunk with other function to force validation of value returned by thunk
                Utils::invariant(is_array(value) || is_callable(value), err, "array or callable");
            } else {
                Utils::invariant(is_array(value), err, "array");
            }
            if !(empty(def->isArray)) {
                if def->flags & self::REQUIRED {
                    Utils::invariant(!(empty(value)), "Error in \"" . typeName . "\" type definition: " . "Value at '{pathStr}' cannot be empty array");
                }
                let err =  "Error in \"" . typeName . "\" type definition: " . "Each entry at '{pathStr}' must be an array, but entry at '%s' is '%s'";
                for arrKey, arrValue in value {
                    if is_array(def->definition) {
                        if def->flags & self::MAYBE_TYPE && arrValue instanceof Type {
                            let arrValue =  ["type" : arrValue];
                        }
                        if def->flags & self::MAYBE_NAME && is_string(arrValue) {
                            let arrValue =  ["name" : arrValue];
                        }
                        if !(arrValue instanceof FieldDefinition) {
                            Utils::invariant(is_array(arrValue), err, arrKey, Utils::getVariableType(arrValue));
                            if def->flags & self::KEY_AS_NAME && is_string(arrKey) {
                                let arrValue = this->array_plus(arrValue, ["name" : arrKey]);
                            }
                            self::validateMap(typeName, arrValue, def->definition, "{pathStr}:{arrKey}");
                        }
                    } else {
                        self::validateEntry(typeName, arrKey, arrValue, def->definition, "{pathStr}:{arrKey}");
                    }
                }
            } else {
                throw new InvariantViolation("Error in \"" . typeName . "\" type definition: " . "unexpected definition: " . print_r(def, true));
            }
        } else {
            Utils::invariant(is_int(def), "Error in \"" . typeName . "\" type definition: " . "Definition for '{pathStr}' is expected to be single integer value");
            if def & self::REQUIRED {
                Utils::invariant(value !== null, "Error in \"" . typeName . "\" type definition: " . "Value at \"%s\" can not be null", pathStr);
            }
            if value === null {
                return;
            }
            if def & self::ANY || def & self::BOOLEAN {
                Utils::invariant(is_bool(value), err, "boolean");
            } elseif def & self::OBJECT_TYPE {
                Utils::invariant(is_callable(value) || value instanceof ObjectType, err, "ObjectType definition");
            } elseif def & self::INTERFACE_TYPE {
                Utils::invariant(is_callable(value) || value instanceof InterfaceType, err, "InterfaceType definition");
            } elseif def & self::OUTPUT_TYPE {
                Utils::invariant(is_callable(value) || value instanceof OutputType, err, "OutputType definition");
            } elseif def & self::INPUT_TYPE {
                Utils::invariant(is_callable(value) || value instanceof InputType, err, "InputType definition");
            } elseif def & self::NAME {
                Utils::invariant(is_string(value), err, "name");
                Utils::invariant(preg_match("~^[_a-zA-Z][_a-zA-Z0-9]*$~", value), "Names must match /^[_a-zA-Z][_a-zA-Z0-9]*$/ but \"%s\" does not.", value);
            } elseif def & self::SCALAR {
                Utils::invariant(is_scalar(value), err, "scalar");
            } elseif def & self::CALLBACK {
                Utils::invariant(is_callable(value), err, "callable");
            } elseif def & self::INT {
                Utils::invariant(is_int(value), err, "int");
            } elseif def & self::FLOAT {
                Utils::invariant(is_float(value) || is_int(value), err, "float");
            } elseif def & self::NUMERIC {
                Utils::invariant(is_numeric(value), err, "numeric");
            } elseif def & self::STRING {
                Utils::invariant(is_string(value), err, "string");
            } else {
                throw new InvariantViolation("Unexpected validation rule: " . def);
            }
        }
    }
    
    /**
     * @param $def
     * @return mixed
     */
    protected static function getFlags(def)
    {
        return  is_object(def) ? def->flags  : def;
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