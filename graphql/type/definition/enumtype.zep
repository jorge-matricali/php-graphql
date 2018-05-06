namespace GraphQL\Type\Definition;

use GraphQL\Error\InvariantViolation;
use GraphQL\Language\AST\EnumTypeDefinitionNode;
use GraphQL\Language\AST\EnumValueNode;
use GraphQL\Utils\MixedStore;
use GraphQL\Utils\Utils;
/**
 * Class EnumType
 * @package GraphQL\Type\Definition
 */
class EnumType extends Type implements InputType, OutputType, LeafType, NamedType
{
    /**
     * @var EnumTypeDefinitionNode|null
     */
    public astNode;
    /**
     * @var EnumValueDefinition[]
     */
    protected values;
    /**
     * @var MixedStore<mixed, EnumValueDefinition>
     */
    protected valueLookup;
    /**
     * @var \ArrayObject<string, EnumValueDefinition>
     */
    protected nameLookup;
    public function __construct(config) -> void
    {
        var tmpArray34442abd526feaa30659cb1a3dbc9c02, tmpArray1a9ef275f15282e82f6fa63449491550;
    
        if !(isset config["name"]) {
            let config["name"] =  this->tryInferName();
        }
        Utils::invariant(is_string(config["name"]), "Must provide name.");
        Config::validate(config, ["name" : Config::NAME | Config::REQUIRED, "values" : Config::arrayOf(tmpArray1a9ef275f15282e82f6fa63449491550, Config::KEY_AS_NAME | Config::MAYBE_NAME), "description" : Config::STRING]);
        let this->name = config["name"];
        let this->description =  isset config["description"] ? config["description"]  : null;
        let this->astNode =  isset config["astNode"] ? config["astNode"]  : null;
        let this->config = config;
    }
    
    /**
     * @return EnumValueDefinition[]
     */
    public function getValues() -> array
    {
        var config, name, value;
    
        if this->values === null {
            let this->values =  [];
            let config =  this->config;
            if isset config["values"] {
                if !(is_array(config["values"])) {
                    throw new InvariantViolation("{this->name} values must be an array");
                }
                for name, value in config["values"] {
                    if is_string(name) {
                        if !(is_array(value)) {
                            let value =  ["name" : name, "value" : value];
                        } else {
                            let value = this->array_plus(value, ["name" : name, "value" : name]);
                        }
                    } else {
                        if is_int(name) && is_string(value) {
                            let value =  ["name" : value, "value" : value];
                        } else {
                            throw new InvariantViolation("{this->name} values must be an array with value names as keys.");
                        }
                    }
                    let this->values[] = new EnumValueDefinition(value);
                }
            }
        }
        return this->values;
    }
    
    /**
     * @param $name
     * @return EnumValueDefinition|null
     */
    public function getValue(name)
    {
        var lookup;
    
        let lookup =  this->getNameLookup();
        return  is_scalar(name) && isset lookup[name] ? lookup[name]  : null;
    }
    
    /**
     * @param $value
     * @return null
     */
    public function serialize(value)
    {
        var lookup;
    
        let lookup =  this->getValueLookup();
        if isset lookup[value] {
            return lookup[value]->name;
        }
        return Utils::undefined();
    }
    
    /**
     * @param $value
     * @return null
     */
    public function parseValue(value)
    {
        var lookup;
    
        let lookup =  this->getNameLookup();
        return  isset lookup[value] ? lookup[value]->value  : Utils::undefined();
    }
    
    /**
     * @param $value
     * @param array|null $variables
     * @return null
     */
    public function parseLiteral(value, array variables = null)
    {
        var lookup, enumValue;
    
        if value instanceof EnumValueNode {
            let lookup =  this->getNameLookup();
            if isset lookup[value->value] {
                let enumValue = lookup[value->value];
                if enumValue {
                    return enumValue->value;
                }
            }
        }
        return null;
    }
    
    /**
     * @return MixedStore<mixed, EnumValueDefinition>
     */
    protected function getValueLookup()
    {
        var valueName, value;
    
        if this->valueLookup === null {
            let this->valueLookup =  new MixedStore();
            for valueName, value in this->getValues() {
                this->valueLookup->offsetSet(value->value, value);
            }
        }
        return this->valueLookup;
    }
    
    /**
     * @return \ArrayObject<string, EnumValueDefinition>
     */
    protected function getNameLookup()
    {
        var lookup, value;
    
        if !(this->nameLookup) {
            let lookup =  new \ArrayObject();
            for value in this->getValues() {
                let lookup[value->name] = value;
            }
            let this->nameLookup = lookup;
        }
        return this->nameLookup;
    }
    
    /**
     * @throws InvariantViolation
     */
    public function assertValid() -> void
    {
        var values, value;
    
        parent::assertValid();
        Utils::invariant(isset this->config["values"], "{this->name} values must be an array.");
        let values =  this->getValues();
        for value in values {
            Utils::invariant(!(isset value->config["isDeprecated"]), "{this->name}.{value->name} should provide \"deprecationReason\" instead of \"isDeprecated\".");
        }
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