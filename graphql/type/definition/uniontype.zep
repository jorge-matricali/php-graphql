namespace GraphQL\Type\Definition;

use GraphQL\Error\InvariantViolation;
use GraphQL\Language\AST\UnionTypeDefinitionNode;
use GraphQL\Utils\Utils;
/**
 * Class UnionType
 * @package GraphQL\Type\Definition
 */
class UnionType extends Type implements AbstractType, OutputType, CompositeType, NamedType
{
    /**
     * @var UnionTypeDefinitionNode
     */
    public astNode;
    /**
     * @var ObjectType[]
     */
    protected types;
    /**
     * @var ObjectType[]
     */
    protected possibleTypeNames;
    /**
     * UnionType constructor.
     * @param $config
     */
    public function __construct(config) -> void
    {
        var tmpArrayfa24b26c48c5f7e4d79fb1e24cb617d1;
    
        if !(isset config["name"]) {
            let config["name"] =  this->tryInferName();
        }
        Utils::invariant(is_string(config["name"]), "Must provide name.");
        Config::validate(config, ["name" : Config::NAME | Config::REQUIRED, "types" : Config::arrayOf(Config::OBJECT_TYPE, Config::MAYBE_THUNK | Config::REQUIRED), "resolveType" : Config::CALLBACK, "description" : Config::STRING]);
        /**
         * Optionally provide a custom type resolver function. If one is not provided,
         * the default implemenation will call `isTypeOf` on each implementing
         * Object type.
         */
        let this->name = config["name"];
        let this->description =  isset config["description"] ? config["description"]  : null;
        let this->astNode =  isset config["astNode"] ? config["astNode"]  : null;
        let this->config = config;
    }
    
    /**
     * @return ObjectType[]
     */
    public function getPossibleTypes() -> array
    {
        trigger_error(__METHOD__ . " is deprecated in favor of " . __CLASS__ . "::getTypes()", E_USER_DEPRECATED);
        return this->getTypes();
    }
    
    /**
     * @return ObjectType[]
     */
    public function getTypes() -> array
    {
        var types;
    
        if this->types === null {
            if !(isset this->config["types"]) {
                let types =  null;
            } else {
                if is_callable(this->config["types"]) {
                    let types =  call_user_func(this->config["types"]);
                } else {
                    let types = this->config["types"];
                }
            }
            if !(is_array(types)) {
                throw new InvariantViolation("Must provide Array of types or a callable which returns " . "such an array for Union {this->name}");
            }
            let this->types = types;
        }
        return this->types;
    }
    
    /**
     * @param Type $type
     * @return mixed
     */
    public function isPossibleType(<Type> type)
    {
        var possibleType;
    
        if !(type instanceof ObjectType) {
            return false;
        }
        if this->possibleTypeNames === null {
            let this->possibleTypeNames =  [];
            for possibleType in this->getTypes() {
                let this->possibleTypeNames[possibleType->name] = true;
            }
        }
        return isset this->possibleTypeNames[type->name];
    }
    
    /**
     * Resolves concrete ObjectType for given object value
     *
     * @param $objectValue
     * @param $context
     * @param ResolveInfo $info
     * @return callable|null
     */
    public function resolveType(objectValue, context, <ResolveInfo> info)
    {
        var fn;
    
        if isset this->config["resolveType"] {
            let fn = this->config["resolveType"];
            return {fn}(objectValue, context, info);
        }
        return null;
    }
    
    /**
     * @throws InvariantViolation
     */
    public function assertValid() -> void
    {
        parent::assertValid();
        if isset this->config["resolveType"] {
            Utils::invariant(is_callable(this->config["resolveType"]), "{this->name} must provide \"resolveType\" as a function.");
        }
    }

}