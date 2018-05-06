namespace GraphQL\Type\Definition;

use GraphQL\Error\InvariantViolation;
use GraphQL\Language\AST\InterfaceTypeDefinitionNode;
use GraphQL\Language\AST\InterfaceTypeExtensionNode;
use GraphQL\Utils\Utils;
/**
 * Class InterfaceType
 * @package GraphQL\Type\Definition
 */
class InterfaceType extends Type implements AbstractType, OutputType, CompositeType, NamedType
{
    /**
     * @param mixed $type
     * @return self
     */
    public static function assertInterfaceType(type)
    {
        Utils::invariant(type instanceof self, "Expected " . Utils::printSafe(type) . " to be a GraphQL Interface type.");
        return type;
    }
    
    /**
     * @var FieldDefinition[]
     */
    protected fields;
    /**
     * @var InterfaceTypeDefinitionNode|null
     */
    public astNode;
    /**
     * @var InterfaceTypeExtensionNode[]
     */
    public extensionASTNodes;
    /**
     * InterfaceType constructor.
     * @param array $config
     */
    public function __construct(array config) -> void
    {
        var tmpArrayeffafbd9a18a30c2904b208c6b3a0955;
    
        if !(isset config["name"]) {
            let config["name"] =  this->tryInferName();
        }
        Utils::invariant(is_string(config["name"]), "Must provide name.");
        Config::validate(config, ["name" : Config::NAME, "fields" : Config::arrayOf(FieldDefinition::getDefinition(), Config::KEY_AS_NAME | Config::MAYBE_THUNK | Config::MAYBE_TYPE), "resolveType" : Config::CALLBACK, "description" : Config::STRING]);
        let this->name = config["name"];
        let this->description =  isset config["description"] ? config["description"]  : null;
        let this->astNode =  isset config["astNode"] ? config["astNode"]  : null;
        let this->extensionASTNodes =  isset config["extensionASTNodes"] ? config["extensionASTNodes"]  : null;
        let this->config = config;
    }
    
    /**
     * @return FieldDefinition[]
     */
    public function getFields() -> array
    {
        var fields;
    
        if this->fields === null {
            let fields =  isset this->config["fields"] ? this->config["fields"]  : [];
            let this->fields =  FieldDefinition::defineFieldMap(this, fields);
        }
        return this->fields;
    }
    
    /**
     * @param $name
     * @return FieldDefinition
     * @throws \Exception
     */
    public function getField(name) -> <FieldDefinition>
    {
        if this->fields === null {
            this->getFields();
        }
        Utils::invariant(isset this->fields[name], "Field \"%s\" is not defined for type \"%s\"", name, this->name);
        return this->fields[name];
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
        Utils::invariant(!(isset this->config["resolveType"]) || is_callable(this->config["resolveType"]), "{this->name} must provide \"resolveType\" as a function.");
    }

}