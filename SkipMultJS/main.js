var falseRow = [
    [23, 28, 33, 10],
    [19, 18, 17, 8],
    [15, 8, 1, 6]
];

var falseCol = [
    [23, 28, 33],
    [19, 18, 17],
    [15, 8, 1],
    [1, 2, 3]
];

var trueInput = [
    [23, 28, 33],
    [19, 18, 17],
    [15, 8, 1]
];


function checkRows(arr){
    var imax = arr.length;
    var jmax = arr[0].length;

    for (let i = 0; i < imax; i++) {
        var check = [];
        for (let j = 0; j < (jmax-1); j++) {
            var difference = arr[i][j+1] - arr[i][j];
            check.push(difference);
        }
        for (c = 0; c < (check.length - 1); c++) {
            if (check[c] != check[c+1]);
                return false
        }

    }

    return true

};

function checkColumns(arr) {
    var imax = arr.length;
    var jmax = arr[0].length;
    for (j = 0; j < jmax; j++) {
        var check = [];
        for (i = 0; i < (imax-1); i++) {
            var difference = arr[i+1][j] - arr[i][j];
            check.push(difference);
        }

        for (c = 0; c < (check.length -1); c++){
            if (check[c] != check[c+1]);
            return false
        }
    }

    return true
};

function checkMatrix(arr) {
    console.log('Rows equal?');
    console.log(checkRows(arr));
    console.log('columns equal?');
    console.log(checkColumns(arr));
    if ((checkRows(arr) == true) && (checkColumns(arr) ==true)) {
        return true
    }
    else
        return false
};

result = checkMatrix(trueInput);
console.log('Result:');
console.log(result);