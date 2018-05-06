namespace GraphQL\Type\Definition;

use GraphQL\Error\InvariantViolation;
use GraphQL\Language\AST\InputObjectTypeDefinitionNode;
use GraphQL\Utils\Utils;
/**
 * Class InputObjectType
 * @package GraphQL\Type\Definition
 */
class InputObjectType extends Type implements InputType, NamedType
{
    /**
     * @var InputObjectField[]
     */
    protected fields;
    /**
     * @var InputObjectTypeDefinitionNode|null
     */
    public astNode;
    /**
     * InputObjectType constructor.
     * @param array $config
     */
    public function __construct(array config) -> void
    {
        var tmpArray87d2b52e9fefcf9feb46bf57dc8101c9, tmpArraybb1be5ac5b0f687006729985dac0b9fc;
    
        if !(isset config["name"]) {
            let config["name"] =  this->tryInferName();
        }
        Utils::invariant(is_string(config["name"]), "Must provide name.");
        Config::validate(config, ["name" : Config::NAME | Config::REQUIRED, "fields" : Config::arrayOf(tmpArraybb1be5ac5b0f687006729985dac0b9fc, Config::KEY_AS_NAME | Config::MAYBE_THUNK | Config::MAYBE_TYPE), "description" : Config::STRING]);
        let this->config = config;
        let this->name = config["name"];
        let this->astNode =  isset config["astNode"] ? config["astNode"]  : null;
        let this->description =  isset config["description"] ? config["description"]  : null;
    }
    
    /**
     * @return InputObjectField[]
     */
    public function getFields() -> array
    {
        var fields, name, field;
    
        if this->fields === null {
            let this->fields =  [];
            let fields =  isset this->config["fields"] ? this->config["fields"]  : [];
            let fields =  is_callable(fields) ? call_user_func(fields)  : fields;
            if !(is_array(fields)) {
                throw new InvariantViolation("{this->name} fields must be an array or a callable which returns such an array.");
            }
            for name, field in fields {
                if field instanceof Type {
                    let field =  ["type" : field];
                }
                let field =  new InputObjectField(field + ["name" : name]);
                let this->fields[field->name] = field;
            }
        }
        return this->fields;
    }
    
    /**
     * @param string $name
     * @return InputObjectField
     * @throws \Exception
     */
    public function getField(string name) -> <InputObjectField>
    {
        if this->fields === null {
            this->getFields();
        }
        Utils::invariant(isset this->fields[name], "Field '%s' is not defined for type '%s'", name, this->name);
        return this->fields[name];
    }

}