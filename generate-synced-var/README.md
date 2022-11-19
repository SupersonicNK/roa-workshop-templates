# generate_synced_var()

This pair of scripts allows you to generate and split a variable for easier use with the new function [`set_synced_var(player, value)`][set], added in the most recent update. To make the best use of this function, you need to learn bitwise/binary to at least some degree, to allow storing multiple values in the allotted 32 bit space per player slot.

This was made to reduce the amount of binary required, and also make inter-op of templates a little bit easier.

## Usage

1. In your `css_update.gml` script (or whatever script you're generating a synced var from), add this `#define` to the bottom.

    ```gml
    #define generate_synced_var
    ///args chunks...
    ///Given pairs of chunks and their lengths in bits, compiles them into one value.
    //arg format: chunk, bit_length, chunk, bit_length, etc.
    var output = 0;
    var num_chunks = argument_count/2;
    if num_chunks != floor(num_chunks) {
        print("error generating synced var - function formatted wrong.");
        return 0;
    }
    var total_len = 0;
    for (var i = num_chunks-1; i >= 0; i--) {
        var pos = (i*2);
        var shift = (pos-1 >= 0) ? argument[pos-1] : 0;
        total_len += argument[pos+1];
        output = output | argument[pos];
        output = output << shift;
    }
    if total_len > 32 {
        print(`error generating synced var - bit length surpassed 32! (${total_len} bits.)`);
        return 0;
    }
    return real(output);
    ```

2. Figure out how many bits the highest value you want to store can use for each chunk. This is the "bit length" of the chunk.

    - For those new to binary numbers, Binary numbers start from the **right**. The rightmost bit represents *one*, and each bit is double the value of the previous bit. (starting from the right, 1, 2, 4, 8, 16, etc.). To represent a number *between* those bits, you simply add up multiple bits. Here's an example:
        - To represent the number 13, we add together 8, 4, and 1. This is represented in binary as `1101`, requiring 4 bits.
    - The value representable with a number of bits can be defined as **two to the power of b minus one** (`power(2, b)-1` in GML), where **b** is our number of bits.

    - If you're having trouble, you can put in your highest possible value [here][dec2bin] and click convert. The number of bits in the resulting number is what you want.

3. Call the function with the following format:

    `generated_var = generate_synced_var(chunk_1, bit_length_1, chunk_2, bit_length_2...)`

    Each chunk is a pair of values; the chunk itself, aka the value you want to pass into the match, and its corresponding bit length. Then, we need to actually set the synced var using [`set_synced_var(player, value)`][set], which we simply do

    `set_synced_var(player, generated_var)`

    You can also generate the synced var in the same line as setting it, in place of the `generated_var` variable.

4. Add the following `#define` to the bottom of `init.gml` (or whichever script you plan on reading the variable from.)

    ```gml
    #define split_synced_var
    ///args chunk_lengths...
    var num_chunks = argument_count;
    var chunk_arr = array_create(argument_count);
    var player = (room == 113) ? 0 : self.player;
    var synced_var = get_synced_var(player);
    var chunk_offset = 0
    for (var i = 0; i < num_chunks; i++) {
        var chunk_len = argument[i]; //print(chunk_len);
        var chunk_mask = (1 << chunk_len)-1
        chunk_arr[i] = (synced_var >> chunk_offset) & chunk_mask;
        //print(`matching shift = ${chunk_len}`);
        chunk_offset += chunk_len;
    }
    print(chunk_arr);
    return chunk_arr;
    ```

5. Call the function with the following format:

    `split_var = split_synced_var(bit_length_1, bit_length_2...)`

    This function takes the bit lengths you put in the previous function, in the same order, and outputs an array with the values you put in (assuming you put in the correct bit lengths), also in the same order.

[set]: https://rivalsofaether.com/set_synced_var/
[dec2bin]: https://www.rapidtables.com/convert/number/decimal-to-binary.html
