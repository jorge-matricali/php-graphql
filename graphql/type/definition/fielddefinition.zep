namespace GraphQL\Type\Definition;

use GraphQL\Error\InvariantViolation;
use GraphQL\Language\AST\FieldDefinitionNode;
use GraphQL\Language\AST\TypeDefinitionNode;
use GraphQL\Utils\Utils;
/**
 * Class FieldDefinition
 * @package GraphQL\Type\Definition
 * @todo Move complexity-related code to it's own place
 */
class FieldDefinition
{
    const DEFAULT_COMPLEXITY_FN = "GraphQL\\Type\\Definition\\FieldDefinition::defaultComplexity";
    /**
     * @var string
     */
    public name;
    /**
     * @var FieldArgument[]
     */
    public args;
    /**
     * Callback for resolving field value given parent value.
     * Mutually exclusive with `map`
     *
     * @var callable
     */
    public resolveFn;
    /**
     * Callback for mapping list of parent values to list of field values.
     * Mutually exclusive with `resolve`
     *
     * @var callable
     */
    public mapFn;
    /**
     * @var string|null
     */
    public description;
    /**
     * @var string|null
     */
    public deprecationReason;
    /**
     * @var FieldDefinitionNode|null
     */
    public astNode;
    /**
     * Original field definition config
     *
     * @var array
     */
    public config;
    /**
     * @var OutputType
     */
    protected type;
    protected static def;
    /**
     * @return array
     */
    public static function getDefinition() -> array
    {
        var tmpArrayed40e2ad62eba7766d7dc36bbed723a1;
    
        let self::def =  ["name" : Config::NAME | Config::REQUIRED, "type" : Config::OUTPUT_TYPE | Config::REQUIRED, "args" : Config::arrayOf(tmpArrayed40e2ad62eba7766d7dc36bbed723a1, Config::KEY_AS_NAME | Config::MAYBE_TYPE), "resolve" : Config::CALLBACK, "map" : Config::CALLBACK, "description" : Config::STRING, "deprecationReason" : Config::STRING, "complexity" : Config::CALLBACK];
        return  self::def ? self::def : self::def;
    }
    
    public static function defineFieldMap(<Type> type, fields)
    {
        var map, name, field, fieldDef, tmpArray1447d091b59cc74cd9251ee48a94cc8b;
    
        if is_callable(fields) {
            let fields =  {fields}();
        }
        if !(is_array(fields)) {
            throw new InvariantViolation("{type->name} fields must be an array or a callable which returns such an array.");
        }
        let map =  [];
        for name, field in fields {
            if is_array(field) {
                if !(isset field["name"]) && is_string(name) {
                    let field["name"] = name;
                }
                if isset field["args"] && !(is_array(field["args"])) {
                    throw new InvariantViolation("{type->name}.{name} args must be an array.");
                }
                let fieldDef =  self::create(field);
            } else {
                if field instanceof FieldDefinition {
                    let fieldDef = field;
                } else {
                    if is_string(name) && field {
                        let fieldDef =  self::create(["name" : name, "type" : field]);
                    } else {
                        throw new InvariantViolation("{type->name}.{name} field config must be an array, but got: " . Utils::printSafe(field));
                    }
                }
            }
            let map[fieldDef->name] = fieldDef;
        }
        return map;
    }
    
    /**
     * @param array $fields
     * @param string $parentTypeName
     * @deprecated use defineFieldMap instead
     * @return array
     */
    public static function createMap(array fields, string parentTypeName = null) -> array
    {
        var map, name, field, fieldDef, tmpArray41808db3af4bd0734ca5ee2dfb15ea13;
    
        trigger_error(__METHOD__ . " is deprecated, use " . __CLASS__ . "::defineFieldMap() instead", E_USER_DEPRECATED);
        let map =  [];
        for name, field in fields {
            if is_array(field) {
                if !(isset field["name"]) && is_string(name) {
                    let field["name"] = name;
                }
                let fieldDef =  self::create(field);
            } else {
                if field instanceof FieldDefinition {
                    let fieldDef = field;
                } else {
                    if is_string(name) {
                        let fieldDef =  self::create(["name" : name, "type" : field]);
                    } else {
                        throw new InvariantViolation("Unexpected field definition for type {parentTypeName} at field {name}: " . Utils::printSafe(field));
                    }
                }
            }
            let map[fieldDef->name] = fieldDef;
        }
        return map;
    }
    
    /**
     * @param array|Config $field
     * @param string $typeName
     * @return FieldDefinition
     */
    public static function create(field, string typeName = null) -> <FieldDefinition>
    {
        if typeName {
            Config::validateField(typeName, field, self::getDefinition());
        }
        return new self(field);
    }
    
    /**
     * FieldDefinition constructor.
     * @param array $config
     */
    protected function __construct(array config) -> void
    {
        let this->name = config["name"];
        let this->type = config["type"];
        let this->resolveFn =  isset config["resolve"] ? config["resolve"]  : null;
        let this->mapFn =  isset config["map"] ? config["map"]  : null;
        let this->args =  isset config["args"] ? FieldArgument::createMap(config["args"])  : [];
        let this->description =  isset config["description"] ? config["description"]  : null;
        let this->deprecationReason =  isset config["deprecationReason"] ? config["deprecationReason"]  : null;
        let this->astNode =  isset config["astNode"] ? config["astNode"]  : null;
        let this->config = config;
        let this->complexityFn =  isset config["complexity"] ? config["complexity"]  : static::DEFAULT_COMPLEXITY_FN;
    }
    
    /**
     * @param $name
     * @return FieldArgument|null
     */
    public function getArg(name)
    {
        var arg;
    
        for arg in  this->args ? this->args : [] {
            /** @var FieldArgument $arg */
            if arg->name === name {
                return arg;
            }
        }
        return null;
    }
    
    /**
     * @return Type
     */
    public function getType() -> <Type>
    {
        return this->type;
    }
    
    /**
     * @return bool
     */
    public function isDeprecated() -> bool
    {
        return !(!(this->deprecationReason));
    }
    
    /**
     * @return callable|\Closure
     */
    public function getComplexityFn()
    {
        return this->complexityFn;
    }
    
    /**
     * @param Type $parentType
     * @throws InvariantViolation
     */
    public function assertValid(<Type> parentType) -> void
    {
        var e, type;
    
        try {
            Utils::assertValidName(this->name);
        } catch InvariantViolation, e {
            throw new InvariantViolation("{parentType->name}.{this->name}: {e->getMessage()}");
        }
        Utils::invariant(!(isset this->config["isDeprecated"]), "{parentType->name}.{this->name} should provide \"deprecationReason\" instead of \"isDeprecated\".");
        let type =  this->type;
        if type instanceof WrappingType {
            let type =  type->getWrappedType(true);
        }
        Utils::invariant(type instanceof OutputType, "{parentType->name}.{this->name} field type must be Output Type but got: " . Utils::printSafe(this->type));
        Utils::invariant(this->resolveFn === null || is_callable(this->resolveFn), "{parentType->name}.{this->name} field resolver must be a function if provided, but got: %s", Utils::printSafe(this->resolveFn));
    }
    
    /**
     * @param $childrenComplexity
     * @return mixed
     */
    public static function defaultComplexity(childrenComplexity)
    {
        return childrenComplexity + 1;
    }

}