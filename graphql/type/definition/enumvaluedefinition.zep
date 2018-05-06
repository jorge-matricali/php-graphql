namespace GraphQL\Type\Definition;

use GraphQL\Language\AST\EnumValueDefinitionNode;
use GraphQL\Utils\Utils;
/**
 * Class EnumValueDefinition
 * @package GraphQL\Type\Definition
 */
class EnumValueDefinition
{
    /**
     * @var string
     */
    public name;
    /**
     * @var mixed
     */
    public value;
    /**
     * @var string|null
     */
    public deprecationReason;
    /**
     * @var string|null
     */
    public description;
    /**
     * @var EnumValueDefinitionNode|null
     */
    public astNode;
    /**
     * @var array
     */
    public config;
    public function __construct(array config) -> void
    {
        let this->name =  isset config["name"] ? config["name"]  : null;
        let this->value =  isset config["value"] ? config["value"]  : null;
        let this->deprecationReason =  isset config["deprecationReason"] ? config["deprecationReason"]  : null;
        let this->description =  isset config["description"] ? config["description"]  : null;
        let this->astNode =  isset config["astNode"] ? config["astNode"]  : null;
        let this->config = config;
    }
    
    /**
     * @return bool
     */
    public function isDeprecated() -> bool
    {
        return !(!(this->deprecationReason));
    }

}