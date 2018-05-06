namespace GraphQL\Utils;

class FindBreakingChangesfindArgChangesClosureZero
{
    private oldArgDef;

    public function __construct(oldArgDef)
    {
                let this->oldArgDef = oldArgDef;

    }

    public function __invoke(arg)
    {
    return arg->name === this->oldArgDef->name;
    }
}
    