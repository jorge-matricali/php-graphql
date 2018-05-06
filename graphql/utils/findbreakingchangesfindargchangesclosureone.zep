namespace GraphQL\Utils;

class FindBreakingChangesfindArgChangesClosureOne
{
    private newArgDef;

    public function __construct(newArgDef)
    {
                let this->newArgDef = newArgDef;

    }

    public function __invoke(arg)
    {
    return arg->name === this->newArgDef->name;
    }
}
    