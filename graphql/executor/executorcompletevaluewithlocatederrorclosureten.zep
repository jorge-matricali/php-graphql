namespace GraphQL\Executor;

class ExecutorcompleteValueWithLocatedErrorClosureTen
{
    private fieldNodes;
    private path;

    public function __construct(fieldNodes, path)
    {
                let this->fieldNodes = fieldNodes;
        let this->path = path;

    }

    public function __invoke(error)
    {
    return this->exeContext->promises->createRejected(Error::createLocatedError(error, this->fieldNodes, this->path));
    }
}
    