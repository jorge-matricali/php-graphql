namespace GraphQL\Executor;

class ExecutorcompleteObjectValueClosureThirteen
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

    public function __invoke(isTypeOfResult)
    {
    if !(isTypeOfResult) {
        throw this->invalidReturnTypeError(this->returnType, this->result, this->fieldNodes);
    }
    return this->collectAndExecuteSubfields(this->returnType, this->fieldNodes, this->info, this->path, this->result);
    }
}
    