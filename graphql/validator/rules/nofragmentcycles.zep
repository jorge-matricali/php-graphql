namespace GraphQL\Validator\Rules;

use GraphQL\Error\Error;
use GraphQL\Language\AST\FragmentDefinitionNode;
use GraphQL\Language\AST\FragmentSpreadNode;
use GraphQL\Language\AST\Node;
use GraphQL\Language\AST\NodeKind;
use GraphQL\Language\Visitor;
use GraphQL\Utils\Utils;
use GraphQL\Validator\ValidationContext;
class NoFragmentCycles extends AbstractValidationRule
{
    static function cycleErrorMessage(fragName, array spreadNames = [])
    {
        var via;
    
        let via =  !(empty(spreadNames)) ? " via " . implode(", ", spreadNames)  : "";
        return "Cannot spread fragment \"{fragName}\" within itself{via}.";
    }
    
    public visitedFrags;
    public spreadPath;
    public spreadPathIndexByName;
    public function getVisitor(<ValidationContext> context)
    {
        var tmpArrayf0cf7cad2d35b44f31f4b78af978c904;
    
        // Tracks already visited fragments to maintain O(N) and to ensure that cycles
        // are not redundantly reported.
        let this->visitedFrags =  [];
        // Array of AST nodes used to produce meaningful errors
        let this->spreadPath =  [];
        // Position in the spread path
        let this->spreadPathIndexByName =  [];
        let tmpArrayf0cf7cad2d35b44f31f4b78af978c904 = [NodeKind::OPERATION_DEFINITION : new NoFragmentCyclesgetVisitorClosureOne(), NodeKind::FRAGMENT_DEFINITION : new NoFragmentCyclesgetVisitorClosureOne(context)];
        return tmpArrayf0cf7cad2d35b44f31f4b78af978c904;
    }
    
    protected function detectCycleRecursive(<FragmentDefinitionNode> fragment, <ValidationContext> context)
    {
        var fragmentName, spreadNodes, i, spreadNode, spreadName, cycleIndex, spreadFragment, cyclePath, nodes;
    
        let fragmentName =  fragment->name->value;
        let this->visitedFrags[fragmentName] = true;
        let spreadNodes =  context->getFragmentSpreads(fragment);
        if empty(spreadNodes) {
            return;
        }
        let this->spreadPathIndexByName[fragmentName] =  count(this->spreadPath);
        let i = 0;
        for i in range(0, count(spreadNodes)) {
            let spreadNode = spreadNodes[i];
            let spreadName =  spreadNode->name->value;
            let cycleIndex =  isset this->spreadPathIndexByName[spreadName] ? this->spreadPathIndexByName[spreadName]  : null;
            if cycleIndex === null {
                let this->spreadPath[] = spreadNode;
                if empty(this->visitedFrags[spreadName]) {
                    let spreadFragment =  context->getFragment(spreadName);
                    if spreadFragment {
                        this->detectCycleRecursive(spreadFragment, context);
                    }
                }
                array_pop(this->spreadPath);
            } else {
                let cyclePath =  array_slice(this->spreadPath, cycleIndex);
                let nodes = cyclePath;
                if is_array(spreadNode) {
                    let nodes =  array_merge(nodes, spreadNode);
                } else {
                    let nodes[] = spreadNode;
                }
                context->reportError(new Error(self::cycleErrorMessage(spreadName, Utils::map(cyclePath, new NoFragmentCyclesdetectCycleRecursiveClosureOne())), nodes));
            }
        }
        let this->spreadPathIndexByName[fragmentName] = null;
    }

}