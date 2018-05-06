namespace GraphQL\Executor;

class ExecutorcompleteAbstractValueClosureTwelve
{
    private returnType;
    private fieldNodes;
    private info;
    private path;
    private result;

    public function __construct(returnType, fieldNodes, info, path, result)
    {
                let this->returnType = returnType;
        let this->fieldNodes = fieldNodes;
        let this->info = info;
        let this->path = path;
        let this->result = result;

    }

    public function __invoke(resolvedRuntimeType)
    {
    return this->completeObjectValue(this->ensureValidRuntimeType(resolvedRuntimeType, this->returnType, this->fieldNodes, this->info, this->result), this->fieldNodes, this->info, this->path, this->result);
    }
}
    