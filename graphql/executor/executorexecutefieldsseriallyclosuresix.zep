namespace GraphQL\Executor;

class ExecutorexecuteFieldsSeriallyClosureSix
{
    private process;
    private responseName;
    private path;
    private parentType;
    private sourceValue;
    private fieldNodes;

    public function __construct(process, responseName, path, parentType, sourceValue, fieldNodes)
    {
                let this->process = process;
        let this->responseName = responseName;
        let this->path = path;
        let this->parentType = parentType;
        let this->sourceValue = sourceValue;
        let this->fieldNodes = fieldNodes;

    }

    public function __invoke(resolvedResults)
    {
    return {this->process}(resolvedResults, this->responseName, this->path, this->parentType, this->sourceValue, this->fieldNodes);
    }
}
    