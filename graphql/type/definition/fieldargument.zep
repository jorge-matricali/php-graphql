namespace GraphQL\Type\Definition;

use GraphQL\Error\InvariantViolation;
use GraphQL\Language\AST\ArgumentNode;
use GraphQL\Language\AST\InputValueDefinitionNode;
use GraphQL\Utils\Utils;
/**
 * Class FieldArgument
 *
 * @package GraphQL\Type\Definition
 */
class FieldArgument
{
    /**
     * @var string
     */
    public name;
    /**
     * @var mixed
     */
    public defaultValue;
    /**
     * @var string|null
     */
    public description;
    /**
     * @var InputValueDefinitionNode|null
     */
    public astNode;
    /**
     * @var array
     */
    public config;
    /**
     * @var InputType
     */
    protected type;
    /**
     * @var bool
     */
    protected defaultValueExists = false;
    /**
     * @param array $config
     * @return array
     */
    public static function createMap(array config) -> array
    {
        var map, name, argConfig;
    
        let map =  [];
        for name, argConfig in config {
            if !(is_array(argConfig)) {
                let argConfig =  ["type" : argConfig];
            }
            let map[] = new self(argConfig + ["name" : name]);
        }
        return map;
    }
    
    /**
     * FieldArgument constructor.
     * @param array $def
     */
    public function __construct(array def) -> void
    {
        var key, value;
    
        for key, value in def {
            switch (key) {
                case "type":
                    let this->type = value;
                    break;
                case "name":
                    let this->name = value;
                    break;
                case "defaultValue":
                    let this->defaultValue = value;
                    let this->defaultValueExists =  true;
                    break;
                case "description":
                    let this->description = value;
                    break;
                case "astNode":
                    let this->astNode = value;
                    break;
            }
        }
        let this->config = def;
    }
    
    /**
     * @return InputType
     */
    public function getType() -> <InputType>
    {
        return this->type;
    }
    
    /**
     * @return bool
     */
    public function defaultValueExists() -> bool
    {
        return this->defaultValueExists;
    }
    
    public function assertValid(<FieldDefinition> parentField, <Type> parentType) -> void
    {
        var e, type;
    
        try {
            Utils::assertValidName(this->name);
        } catch InvariantViolation, e {
            throw new InvariantViolation("{parentType->name}.{parentField->name}({this->name}:) {e->getMessage()}");
        }
        let type =  this->type;
        if type instanceof WrappingType {
            let type =  type->getWrappedType(true);
        }
        Utils::invariant(type instanceof InputType, "{parentType->name}.{parentField->name}({this->name}): argument type must be " . "Input Type but got: " . Utils::printSafe(this->type));
        Utils::invariant(this->description === null || is_string(this->description), "{parentType->name}.{parentField->name}({this->name}): argument description type must be " . "string but got: " . Utils::printSafe(this->description));
    }

}