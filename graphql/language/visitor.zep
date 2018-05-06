namespace GraphQL\Language;

use GraphQL\Language\AST\Node;
use GraphQL\Language\AST\NodeKind;
use GraphQL\Language\AST\NodeList;
use GraphQL\Utils\TypeInfo;
/**
 * Utility for efficient AST traversal and modification.
 *
 * `visit()` will walk through an AST using a depth first traversal, calling
 * the visitor's enter function at each node in the traversal, and calling the
 * leave function after visiting that node and all of it's child nodes.
 *
 * By returning different values from the enter and leave functions, the
 * behavior of the visitor can be altered, including skipping over a sub-tree of
 * the AST (by returning false), editing the AST by returning a value or null
 * to remove the value, or to stop the whole traversal by returning BREAK.
 *
 * When using `visit()` to edit an AST, the original AST will not be modified, and
 * a new version of the AST with the changes applied will be returned from the
 * visit function.
 *
 *     $editedAST = Visitor::visit($ast, [
 *       'enter' => function ($node, $key, $parent, $path, $ancestors) {
 *         // return
 *         //   null: no action
 *         //   Visitor::skipNode(): skip visiting this node
 *         //   Visitor::stop(): stop visiting altogether
 *         //   Visitor::removeNode(): delete this node
 *         //   any value: replace this node with the returned value
 *       },
 *       'leave' => function ($node, $key, $parent, $path, $ancestors) {
 *         // return
 *         //   null: no action
 *         //   Visitor::stop(): stop visiting altogether
 *         //   Visitor::removeNode(): delete this node
 *         //   any value: replace this node with the returned value
 *       }
 *     ]);
 *
 * Alternatively to providing enter() and leave() functions, a visitor can
 * instead provide functions named the same as the [kinds of AST nodes](reference.md#graphqllanguageastnodekind),
 * or enter/leave visitors at a named key, leading to four permutations of
 * visitor API:
 *
 * 1) Named visitors triggered when entering a node a specific kind.
 *
 *     Visitor::visit($ast, [
 *       'Kind' => function ($node) {
 *         // enter the "Kind" node
 *       }
 *     ]);
 *
 * 2) Named visitors that trigger upon entering and leaving a node of
 *    a specific kind.
 *
 *     Visitor::visit($ast, [
 *       'Kind' => [
 *         'enter' => function ($node) {
 *           // enter the "Kind" node
 *         }
 *         'leave' => function ($node) {
 *           // leave the "Kind" node
 *         }
 *       ]
 *     ]);
 *
 * 3) Generic visitors that trigger upon entering and leaving any node.
 *
 *     Visitor::visit($ast, [
 *       'enter' => function ($node) {
 *         // enter any node
 *       },
 *       'leave' => function ($node) {
 *         // leave any node
 *       }
 *     ]);
 *
 * 4) Parallel visitors for entering and leaving nodes of a specific kind.
 *
 *     Visitor::visit($ast, [
 *       'enter' => [
 *         'Kind' => function($node) {
 *           // enter the "Kind" node
 *         }
 *       },
 *       'leave' => [
 *         'Kind' => function ($node) {
 *           // leave the "Kind" node
 *         }
 *       ]
 *     ]);
 */
class Visitor
{
    public static visitorKeys = [NodeKind::NAME : [], NodeKind::DOCUMENT : ["definitions"], NodeKind::OPERATION_DEFINITION : ["name", "variableDefinitions", "directives", "selectionSet"], NodeKind::VARIABLE_DEFINITION : ["variable", "type", "defaultValue"], NodeKind::VARIABLE : ["name"], NodeKind::SELECTION_SET : ["selections"], NodeKind::FIELD : ["alias", "name", "arguments", "directives", "selectionSet"], NodeKind::ARGUMENT : ["name", "value"], NodeKind::FRAGMENT_SPREAD : ["name", "directives"], NodeKind::INLINE_FRAGMENT : ["typeCondition", "directives", "selectionSet"], NodeKind::FRAGMENT_DEFINITION : ["name", "variableDefinitions", "typeCondition", "directives", "selectionSet"], NodeKind::INT : [], NodeKind::FLOAT : [], NodeKind::STRING : [], NodeKind::BOOLEAN : [], NodeKind::NULL : [], NodeKind::ENUM : [], NodeKind::LST : ["values"], NodeKind::OBJECT : ["fields"], NodeKind::OBJECT_FIELD : ["name", "value"], NodeKind::DIRECTIVE : ["name", "arguments"], NodeKind::NAMED_TYPE : ["name"], NodeKind::LIST_TYPE : ["type"], NodeKind::NON_NULL_TYPE : ["type"], NodeKind::SCHEMA_DEFINITION : ["directives", "operationTypes"], NodeKind::OPERATION_TYPE_DEFINITION : ["type"], NodeKind::SCALAR_TYPE_DEFINITION : ["description", "name", "directives"], NodeKind::OBJECT_TYPE_DEFINITION : ["description", "name", "interfaces", "directives", "fields"], NodeKind::FIELD_DEFINITION : ["description", "name", "arguments", "type", "directives"], NodeKind::INPUT_VALUE_DEFINITION : ["description", "name", "type", "defaultValue", "directives"], NodeKind::INTERFACE_TYPE_DEFINITION : ["description", "name", "directives", "fields"], NodeKind::UNION_TYPE_DEFINITION : ["description", "name", "directives", "types"], NodeKind::ENUM_TYPE_DEFINITION : ["description", "name", "directives", "values"], NodeKind::ENUM_VALUE_DEFINITION : ["description", "name", "directives"], NodeKind::INPUT_OBJECT_TYPE_DEFINITION : ["description", "name", "directives", "fields"], NodeKind::SCALAR_TYPE_EXTENSION : ["name", "directives"], NodeKind::OBJECT_TYPE_EXTENSION : ["name", "interfaces", "directives", "fields"], NodeKind::INTERFACE_TYPE_EXTENSION : ["name", "directives", "fields"], NodeKind::UNION_TYPE_EXTENSION : ["name", "directives", "types"], NodeKind::ENUM_TYPE_EXTENSION : ["name", "directives", "values"], NodeKind::INPUT_OBJECT_TYPE_EXTENSION : ["name", "directives", "fields"], NodeKind::DIRECTIVE_DEFINITION : ["description", "name", "arguments", "locations"]];
    /**
     * Visit the AST (see class description for details)
     *
     * @api
     * @param Node $root
     * @param array $visitor
     * @param array $keyMap
     * @return Node|mixed
     * @throws \Exception
     */
    public static function visit(<Node> root, array visitor, array keyMap = null)
    {
        var visitorKeys, stack, inArray, keys, index, edits, parent, path, ancestors, newRoot, undefined, isLeaving, key, node, isEdited, editOffset, ii, editKey, editValue, result, visitFn;
    
        let visitorKeys =  keyMap ? keyMap : self::visitorKeys;
        let stack =  null;
        let inArray =  root instanceof NodeList || is_array(root);
        let keys =  [root];
        let index =  -1;
        let edits =  [];
        let parent =  null;
        let path =  [];
        let ancestors =  [];
        let newRoot = root;
        let undefined =  null;
        do {
            let index++;
            let isLeaving =  index === count(keys);
            let key =  null;
            let node =  null;
            let isEdited =  isLeaving && count(edits) !== 0;
            if isLeaving {
                let key =  !(ancestors) ? undefined  : path[count(path) - 1];
                let node = parent;
                let parent =  array_pop(ancestors);
                if isEdited {
                    if inArray {
                        // $node = $node; // arrays are value types in PHP
                        if node instanceof NodeList {
                            let node =  clone node;
                        }
                    } else {
                        let node =  clone node;
                    }
                    let editOffset = 0;
                    let ii = 0;
                    for ii in range(0, count(edits)) {
                        let editKey = edits[ii][0];
                        let editValue = edits[ii][1];
                        if inArray {
                            let editKey -= editOffset;
                        }
                        if inArray && editValue === null {
                            if node instanceof NodeList {
                                node->splice(editKey, 1);
                            } else {
                                array_splice(node, editKey, 1);
                            }
                            let editOffset++;
                        } else {
                            if node instanceof NodeList || is_array(node) {
                                let node[editKey] = editValue;
                            } else {
                                let node->{editKey} = editValue;
                            }
                        }
                    }
                }
                let index = stack["index"];
                let keys = stack["keys"];
                let edits = stack["edits"];
                let inArray = stack["inArray"];
                let stack = stack["prev"];
            } else {
                let key =  parent ?  inArray ? index  : keys[index]  : undefined;
                let node =  parent ?  parent instanceof NodeList || is_array(parent) ? parent[key]  : parent->{key}  : newRoot;
                if node === null || node === undefined {
                    continue;
                }
                if parent {
                    let path[] = key;
                }
            }
            let result =  null;
            if !(node instanceof NodeList) && !(is_array(node)) {
                if !(node instanceof Node) {
                    throw new \Exception("Invalid AST Node: " . json_encode(node));
                }
                let visitFn =  self::getVisitFn(visitor, node->kind, isLeaving);
                if visitFn {
                    let result =  call_user_func(visitFn, node, key, parent, path, ancestors);
                    if result !== null {
                        if result instanceof VisitorOperation {
                            if result->doBreak {
                                break;
                            }
                            if !(isLeaving) && result->doContinue {
                                array_pop(path);
                                continue;
                            }
                            if result->removeNode {
                                let editValue =  null;
                            }
                        } else {
                            let editValue = result;
                        }
                        let edits[] =  [key, editValue];
                        if !(isLeaving) {
                            if editValue instanceof Node {
                                let node = editValue;
                            } else {
                                array_pop(path);
                                continue;
                            }
                        }
                    }
                }
            }
            if result === null && isEdited {
                let edits[] =  [key, node];
            }
            if isLeaving {
                array_pop(path);
            } else {
                let stack =  ["inArray" : inArray, "index" : index, "keys" : keys, "edits" : edits, "prev" : stack];
                let inArray =  node instanceof NodeList || is_array(node);
                let keys =   inArray ? node  : visitorKeys[node->kind] ?  inArray ? node  : visitorKeys[node->kind] : [];
                let index =  -1;
                let edits =  [];
                if parent {
                    let ancestors[] = parent;
                }
                let parent = node;
            }
        } while (stack);
        if count(edits) !== 0 {
            let newRoot = edits[0][1];
        }
        return newRoot;
    }
    
    /**
     * Returns marker for visitor break
     *
     * @api
     * @return VisitorOperation
     */
    public static function stop() -> <VisitorOperation>
    {
        var r;
    
        let r =  new VisitorOperation();
        let r->doBreak =  true;
        return r;
    }
    
    /**
     * Returns marker for skipping current node
     *
     * @api
     * @return VisitorOperation
     */
    public static function skipNode() -> <VisitorOperation>
    {
        var r;
    
        let r =  new VisitorOperation();
        let r->doContinue =  true;
        return r;
    }
    
    /**
     * Returns marker for removing a node
     *
     * @api
     * @return VisitorOperation
     */
    public static function removeNode() -> <VisitorOperation>
    {
        var r;
    
        let r =  new VisitorOperation();
        let r->removeNode =  true;
        return r;
    }
    
    /**
     * @param $visitors
     * @return array
     */
    static function visitInParallel(visitors) -> array
    {
        var visitorsCount, skipping, tmpArrayc680ae1e7e39eedaef9a45fbbdd6f53f, i, fn, result;
    
        let visitorsCount =  count(visitors);
        let skipping =  new \SplFixedArray(visitorsCount);
        let i = 0;
        let i++;
        let fn =  self::getVisitFn(visitors[i], node->kind, false);
        let result =  call_user_func_array(fn, func_get_args());
        let skipping[i] = node;
        let skipping[i] = result;
        let i = 0;
        let i++;
        let fn =  self::getVisitFn(visitors[i], node->kind, true);
        let result =  call_user_func_array(fn, func_get_args());
        let skipping[i] = result;
        let skipping[i] = null;
        let tmpArrayc680ae1e7e39eedaef9a45fbbdd6f53f = let i = 0;
        let i++;
        let fn =  self::getVisitFn(visitors[i], node->kind, false);
        let result =  call_user_func_array(fn, func_get_args());
        let skipping[i] = node;
        let skipping[i] = result;
        let i = 0;
        let i++;
        let fn =  self::getVisitFn(visitors[i], node->kind, true);
        let result =  call_user_func_array(fn, func_get_args());
        let skipping[i] = result;
        let skipping[i] = null;
        ["enter" : new VisitorvisitInParallelClosureOne(visitors, skipping, visitorsCount), "leave" : new VisitorvisitInParallelClosureOne(visitors, skipping, visitorsCount)];
        return tmpArray44c1e6bb95b536c73f8bdd9688ae06a2;
    }
    
    /**
     * Creates a new visitor instance which maintains a provided TypeInfo instance
     * along with visiting visitor.
     */
    static function visitWithTypeInfo(<TypeInfo> typeInfo, visitor)
    {
        var tmpArrayf7ef33712084c73dbd212fd6c7b99328, fn, result;
    
        let fn =  self::getVisitFn(visitor, node->kind, false);
        let result =  call_user_func_array(fn, func_get_args());
        let fn =  self::getVisitFn(visitor, node->kind, true);
        let result =  fn ? call_user_func_array(fn, func_get_args())  : null;
        let tmpArrayf7ef33712084c73dbd212fd6c7b99328 = let fn =  self::getVisitFn(visitor, node->kind, false);
        let result =  call_user_func_array(fn, func_get_args());
        let fn =  self::getVisitFn(visitor, node->kind, true);
        let result =  fn ? call_user_func_array(fn, func_get_args())  : null;
        ["enter" : new VisitorvisitWithTypeInfoClosureOne(typeInfo, visitor), "leave" : new VisitorvisitWithTypeInfoClosureOne(typeInfo, visitor)];
        return tmpArrayc7b4f497d9f8760e43d5e96be2c23845;
    }
    
    /**
     * @param $visitor
     * @param $kind
     * @param $isLeaving
     * @return null
     */
    public static function getVisitFn(visitor, kind, isLeaving) -> null
    {
        var kindVisitor, kindSpecificVisitor, specificVisitor, specificKindVisitor;
    
        if !(visitor) {
            return null;
        }
        let kindVisitor =  isset visitor[kind] ? visitor[kind]  : null;
        if !(isLeaving) && is_callable(kindVisitor) {
            // { Kind() {} }
            return kindVisitor;
        }
        if is_array(kindVisitor) {
            if isLeaving {
                let kindSpecificVisitor =  isset kindVisitor["leave"] ? kindVisitor["leave"]  : null;
            } else {
                let kindSpecificVisitor =  isset kindVisitor["enter"] ? kindVisitor["enter"]  : null;
            }
            if kindSpecificVisitor && is_callable(kindSpecificVisitor) {
                // { Kind: { enter() {}, leave() {} } }
                return kindSpecificVisitor;
            }
            return null;
        }
        let visitor = this->array_plus(visitor, ["leave" : null, "enter" : null]);
        let specificVisitor =  isLeaving ? visitor["leave"]  : visitor["enter"];
        if specificVisitor {
            if is_callable(specificVisitor) {
                // { enter() {}, leave() {} }
                return specificVisitor;
            }
            let specificKindVisitor =  isset specificVisitor[kind] ? specificVisitor[kind]  : null;
            if is_callable(specificKindVisitor) {
                // { enter: { Kind() {} }, leave: { Kind() {} } }
                return specificKindVisitor;
            }
        }
        return null;
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