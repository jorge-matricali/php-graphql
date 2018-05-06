namespace GraphQL\Error;

class ErrorgetLocationsClosureTwo
{
    private source;

    public function __construct(source)
    {
                let this->source = source;

    }

    public function __invoke(pos)
    {
    return this->source->getLocation(pos);
    }
}
    