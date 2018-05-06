namespace GraphQL\Language\AST;

use GraphQL\Error\InvariantViolation;
use GraphQL\Utils\Utils;
abstract class Node
{
    /**
     type Node = NameNode
        | DocumentNode
        | OperationDefinitionNode
        | VariableDefinitionNode
        | VariableNode
        | SelectionSetNode
        | FieldNode
        | ArgumentNode
        | FragmentSpreadNode
        | InlineFragmentNode
        | FragmentDefinitionNode
        | IntValueNode
        | FloatValueNode
        | StringValueNode
        | BooleanValueNode
        | EnumValueNode
        | ListValueNode
        | ObjectValueNode
        | ObjectFieldNode
        | DirectiveNode
        | ListTypeNode
        | NonNullTypeNode
    */
    public kind;
    /**
     * @var Location
     */
    public loc;
    /**
     * @param array $vars
     */
    public function __construct(array vars) -> void
    {
        if !(empty(vars)) {
            Utils::assign(this, vars);
        }
    }
    
    /**
     * @return $this
     */
    public function cloneDeep()
    {
        return this->cloneValue(this);
    }
    
    /**
     * @param $value
     * @return array|Node
     */
    protected function cloneValue(value)
    {
        var cloned, key, arrValue, prop, propValue;
    
        if is_array(value) {
            let cloned =  [];
            for key, arrValue in value {
                let cloned[key] =  this->cloneValue(arrValue);
            }
        } else {
            if value instanceof Node {
                let cloned =  clone value;
                for prop, propValue in get_object_vars(cloned) {
                    let cloned->{prop} =  this->cloneValue(propValue);
                }
            } else {
                let cloned = value;
            }
        }
        return cloned;
    }
    
    /**
     * @return string
     */
    public function __toString() -> string
    {
        var tmp;
    
        let tmp =  this->toArray(true);
        return json_encode(tmp);
    }
    
    /**
     * @param bool $recursive
     * @return array
     */
    public function toArray(bool recursive = false) -> array
    {
        var tmp;
    
        if recursive {
            return this->recursiveToArray(this);
        } else {
            let tmp =  (array) this;
            if this->loc {
                let tmp["loc"] =  ["start" : this->loc->start, "end" : this->loc->end];
            }
            return tmp;
        }
    }
    
    /**
     * @param Node $node
     * @return array
     */
    protected function recursiveToArray(<Node> node) -> array
    {
        var result, prop, propValue, tmp, tmp1;
    
        let result =  ["kind" : node->kind];
        if node->loc {
            let result["loc"] =  ["start" : node->loc->start, "end" : node->loc->end];
        }
        for prop, propValue in get_object_vars(node) {
            if isset result[prop] {
                continue;
            }
            if propValue === null {
                continue;
            }
            if is_array(propValue) || propValue instanceof NodeList {
                let tmp =  [];
                for tmp1 in propValue {
                    let tmp[] =  tmp1 instanceof Node ? this->recursiveToArray(tmp1)  : (array) tmp1;
                }
            } else {
                if propValue instanceof Node {
                    let tmp =  this->recursiveToArray(propValue);
                } else {
                    if is_scalar(propValue) || propValue === null {
                        let tmp = propValue;
                    } else {
                        let tmp =  null;
                    }
                }
            }
            let result[prop] = tmp;
        }
        return result;
    }

}