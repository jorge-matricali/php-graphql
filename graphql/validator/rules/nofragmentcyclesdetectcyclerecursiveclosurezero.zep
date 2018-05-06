namespace GraphQL\Validator\Rules;

class NoFragmentCyclesdetectCycleRecursiveClosureZero
{

    public function __construct()
    {
        
    }

    public function __invoke(s)
    {
    return s->name->value;
    }
}
    