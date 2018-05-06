namespace GraphQL\Utils;

class UtilsorListClosureThree
{
    private selected;
    private selectedLength;

    public function __construct(selected, selectedLength)
    {
                let this->selected = selected;
        let this->selectedLength = selectedLength;

    }

    public function __invoke(list, index)
    {
    return list . ( this->selectedLength > 2 ? ", "  : " ") . ( index === this->selectedLength - 1 ? "or "  : "") . this->selected[index];
    }
}
    