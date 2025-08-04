import express,{ Application } from 'express';
import { OtpController} from '../controllers/otp_controller';
import { authenticateToken } from '../services/auth_service';
import { AuthController} from '../controllers/auth_controller';
import { OrderController} from '../controllers/order_controller';
import { upload } from '../services/upload_middleware';
import { CartController} from '../controllers/cart_controller';
import { isAdmin } from '../services/admin_service';
import { ProductController} from '../controllers/product_controller';
import { WishlistController} from '../controllers/wishlist_controller';
import { AdminController} from '../controllers/admin_controller';
import {UserController} from '../controllers/user_controller'

export function configureAuthRoutes(app: Application) {
  app.post('/auth/refresh', AuthController.ioRefreshToken);
  app.post('/auth/login', AuthController.ioLogin);
  app.get('/auth/profile', authenticateToken, AuthController.ioProtectedProfile);

}

export function configureUserRoutes(app: Application) {
  app.post('/user/register', UserController.ioRegisterUser);
  app.get('/user/profile', authenticateToken, UserController.ioGetUserProfile);
}
export function configureVerificationRoutes(app: Application) {
  app.post('/api/number/generate', OtpController.ioGenerateNumber);
  app.get('/api/otp/generate/:number', OtpController.ioGenerateOtp);
  app.post('/api/number/verify', OtpController.ioVerifyNumber);
  app.post('/api/logout', OtpController.ioLogout);
}

export function configureProductRoutes(app: Application) {
  app.post('/product_array/create', authenticateToken,isAdmin, upload.single('productImage'),isAdmin, ProductController.ioCreateProduct);
  app.post('/product_array/getdata', authenticateToken, ProductController.ioGetProductList);
  app.post('/product_array/update', authenticateToken,isAdmin, ProductController.ioUpdateProduct);
  app.post('/product_array/delete', authenticateToken,isAdmin, ProductController.ioDeleteProduct);
}

export function configureCartRoutes(app: Application) {
  app.post('/cart_array/create', authenticateToken, CartController.ioCreateCart);
  app.post('/cart_array/getdata', authenticateToken, CartController.ioGetCartList);
  app.post('/cart_array/update', authenticateToken, CartController.ioUpdateCart);
  app.post('/cart_array/delete', authenticateToken, CartController.ioDeleteCart);
}

export function configureWishlistRoutes(app: Application) {
  app.post('/wishlist/add', authenticateToken, WishlistController.ioAddToWishlist);
  app.get('/wishlist/get', authenticateToken, WishlistController.ioGetWishlist);
  app.post('/wishlist/remove', authenticateToken, WishlistController.ioRemoveFromWishlist);
}

export function configureOrderRoutes(app: Application) {
  app.post('/orders/create', authenticateToken, OrderController.ioCreateOrder);
  app.get('/orders/list', authenticateToken, OrderController.ioGetOrders);
app.put('/orders/update', authenticateToken, isAdmin, OrderController.ioUpdateOrder);
}

export function configureAdminRoutes(app: Application) {
  app.post('/admin/create', AdminController.createAdmin);
  app.get('/admin/users/list', authenticateToken, isAdmin, AdminController.ioGetUsers);
}