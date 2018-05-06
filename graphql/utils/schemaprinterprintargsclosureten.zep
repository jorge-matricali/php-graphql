namespace GraphQL\Utils;

class SchemaPrinterprintArgsClosureTen
{
    private indentation;
    private options;

    public function __construct(indentation, options)
    {
                let this->indentation = indentation;
        let this->options = options;

    }

    public function __invoke(arg, i)
    {
    return self::printDescription(this->options, arg, "  " . this->indentation, !(i)) . "  " . this->indentation . self::printInputValue(arg);
    }
}
    