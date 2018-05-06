namespace GraphQL\Utils;

class TypeInfoenterClosureOne
{
    private node;

    public function __construct(node)
    {
                let this->node = node;

    }

    public function __invoke(arg)
    {
    return arg->name === this->node->name->value;
    }
}
    