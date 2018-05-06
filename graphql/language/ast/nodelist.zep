namespace GraphQL\Language\AST;

use GraphQL\Utils\AST;
/**
 * Class NodeList
 *
 * @package GraphQL\Utils
 */
class NodeList implements \ArrayAccess, \IteratorAggregate, \Countable
{
    /**
     * @var array
     */
    protected nodes;
    /**
     * @param array $nodes
     * @return static
     */
    public static function create(array nodes) -> <static>
    {
        return new static(nodes);
    }
    
    /**
     * NodeList constructor.
     * @param array $nodes
     */
    public function __construct(array nodes) -> void
    {
        let this->nodes = nodes;
    }
    
    /**
     * @param mixed $offset
     * @return bool
     */
    public function offsetExists(offset) -> bool
    {
        return isset this->nodes[offset];
    }
    
    /**
     * @param mixed $offset
     * @return mixed
     */
    public function offsetGet(offset)
    {
        var item;
    
        let item = this->nodes[offset];
        if is_array(item) && isset item["kind"] {
            let item =  ast::fromArray(item);
            let this->nodes[offset] = item;
        }
        return item;
    }
    
    /**
     * @param mixed $offset
     * @param mixed $value
     */
    public function offsetSet(offset, value) -> void
    {
        if is_array(value) && isset value["kind"] {
            let value =  ast::fromArray(value);
        }
        let this->nodes[offset] = value;
    }
    
    /**
     * @param mixed $offset
     */
    public function offsetUnset(offset) -> void
    {
        unset this->nodes[offset];
    
    }
    
    /**
     * @param int $offset
     * @param int $length
     * @param mixed $replacement
     * @return NodeList
     */
    public function splice(int offset, int length, replacement = null) -> <NodeList>
    {
        return new NodeList(array_splice(this->nodes, offset, length, replacement));
    }
    
    /**
     * @param $list
     * @return NodeList
     */
    public function merge(list) -> <NodeList>
    {
        if list instanceof NodeList {
            let list =  list->nodes;
        }
        return new NodeList(array_merge(this->nodes, list));
    }
    
    /**
     * @return \Generator
     */
    public function getIterator() -> <\Generator>
    {
        var count, i;
    
        let count =  count(this->nodes);
        let i = 0;
        for i in range(0, count) {
            (yield this->offsetGet(i));
        }
    }
    
    /**
     * @return int
     */
    public function count() -> int
    {
        return count(this->nodes);
    }

}