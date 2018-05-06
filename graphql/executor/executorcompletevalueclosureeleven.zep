namespace GraphQL\Executor;

class ExecutorcompleteValueClosureEleven
{
    private returnType;
    private fieldNodes;
    private info;
    private path;

    public function __construct(returnType, fieldNodes, info, path)
    {
                let this->returnType = returnType;
        let this->fieldNodes = fieldNodes;
        let this->info = info;
        let this->path = path;

    }

    public function __invoke(resolved)
    {
    return this->completeValue(this->returnType, this->fieldNodes, this->info, this->path, resolved);
    }
}
    