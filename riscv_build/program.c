// Test C Program for RISC-V32I Multicycle Core

// Memory-mapped locations
volatile int* const DATA_BASE = (volatile int*)0x0;

// Simple test function
int add_numbers(int a, int b) {
    return a + b;
}

int subtract_numbers(int a, int b) {
    return a - b;
}

int main() {
    // Initialize test data
    DATA_BASE[0] = 0x12345678;
    DATA_BASE[1] = 0x87654321;
    
    // Load data
    int a = DATA_BASE[0];
    int b = DATA_BASE[1];
    
    // Perform operations
    int sum = add_numbers(a, b);
    int diff = subtract_numbers(a, b);
    int result = add_numbers(sum, diff);
    
    // Store results
    DATA_BASE[2] = sum;
    DATA_BASE[3] = diff;
    DATA_BASE[4] = result;
    
    // Simple counter loop
    int counter = 0;
    while (1) {
        counter++;
        DATA_BASE[5] = counter;
        
        // Simple delay
        for (int i = 0; i < counter; i++) {
            // Delay loop
        }
    }
    
    return 0;
}
