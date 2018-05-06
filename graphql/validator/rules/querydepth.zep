namespace GraphQL\Validator\Rules;

use GraphQL\Error\Error;
use GraphQL\Language\AST\FieldNode;
use GraphQL\Language\AST\FragmentSpreadNode;
use GraphQL\Language\AST\InlineFragmentNode;
use GraphQL\Language\AST\Node;
use GraphQL\Language\AST\NodeKind;
use GraphQL\Language\AST\OperationDefinitionNode;
use GraphQL\Language\AST\SelectionSetNode;
use GraphQL\Validator\ValidationContext;
class QueryDepth extends AbstractQuerySecurity
{
    /**
     * @var int
     */
    protected maxQueryDepth;
    public function __construct(maxQueryDepth) -> void
    {
        this->setMaxQueryDepth(maxQueryDepth);
    }
    
    /**
     * Set max query depth. If equal to 0 no check is done. Must be greater or equal to 0.
     *
     * @param $maxQueryDepth
     */
    public function setMaxQueryDepth(maxQueryDepth) -> void
    {
        this->checkIfGreaterOrEqualToZero("maxQueryDepth", maxQueryDepth);
        let this->maxQueryDepth =  (int) maxQueryDepth;
    }
    
    public function getMaxQueryDepth()
    {
        return this->maxQueryDepth;
    }
    
    public static function maxQueryDepthErrorMessage(max, count)
    {
        return sprintf("Max query depth should be %d but got %d.", max, count);
    }
    
    public function getVisitor(<ValidationContext> context)
    {
        var tmpArraydcd3db08888d248db270f0d9fb3fbe65, maxDepth;
    
        let tmpArraydcd3db08888d248db270f0d9fb3fbe65 = let maxDepth =  this->fieldDepth(operationDefinition);
        [NodeKind::OPERATION_DEFINITION : ["leave" : new QueryDepthgetVisitorClosureOne(context)]];
        let maxDepth =  this->fieldDepth(operationDefinition);
        return this->invokeIfNeeded(context, tmpArray056add8ac1a59f85f75d65cc178b76e7);
    }
    
    protected function isEnabled()
    {
        return this->getMaxQueryDepth() !== static::DISABLED;
    }
    
    protected function fieldDepth(node, depth = 0, maxDepth = 0)
    {
        var childNode;
    
        if isset node->selectionSet && node->selectionSet instanceof SelectionSetNode {
            for childNode in node->selectionSet->selections {
                let maxDepth =  this->nodeDepth(childNode, depth, maxDepth);
            }
        }
        return maxDepth;
    }
    
    protected function nodeDepth(<Node> node, depth = 0, maxDepth = 0)
    {
        var fragment;
    
        if NodeKind::FIELD {
            /* @var FieldNode $node */
            // node has children?
            if node->selectionSet !== null {
                // update maxDepth if needed
                if depth > maxDepth {
                    let maxDepth = depth;
                }
                let maxDepth =  this->fieldDepth(node, depth + 1, maxDepth);
            }
        } elseif NodeKind::INLINE_FRAGMENT {
            /* @var InlineFragmentNode $node */
            // node has children?
            if node->selectionSet !== null {
                let maxDepth =  this->fieldDepth(node, depth, maxDepth);
            }
        } else {
            /* @var FragmentSpreadNode $node */
            let fragment =  this->getFragment(node);
            if fragment !== null {
                let maxDepth =  this->fieldDepth(fragment, depth, maxDepth);
            }
        }
        return maxDepth;
    }

}