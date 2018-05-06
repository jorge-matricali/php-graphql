namespace GraphQL\Type\Definition;

use GraphQL\Language\AST\InputValueDefinitionNode;
/**
 * Class InputObjectField
 * @package GraphQL\Type\Definition
 */
class InputObjectField
{
    /**
     * @var string
     */
    public name;
    /**
     * @var mixed|null
     */
    public defaultValue;
    /**
     * @var string|null
     */
    public description;
    /**
     * @var callback|InputType
     */
    public type;
    /**
     * @var InputValueDefinitionNode|null
     */
    public astNode;
    /**
     * @var array
     */
    public config;
    /**
     * Helps to differentiate when `defaultValue` is `null` and when it was not even set initially
     *
     * @var bool
     */
    protected defaultValueExists = false;
    /**
     * InputObjectField constructor.
     * @param array $opts
     */
    public function __construct(array opts) -> void
    {
        var k, v;
    
        for k, v in opts {
            switch (k) {
                case "defaultValue":
                    let this->defaultValue = v;
                    let this->defaultValueExists =  true;
                    break;
                case "defaultValueExists":
                    break;
                default:
                    let this->{k} = v;
            }
        }
        let this->config = opts;
    }
    
    /**
     * @return mixed
     */
    public function getType()
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

}